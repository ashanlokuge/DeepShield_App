# Integrating your INT8 model

DeepShield's Dart code doesn't hardcode any model-specific numbers —
it reads everything it needs (input size, input dtype, output shape,
quantization scale/zero-point) directly from the `.tflite` file at
startup. In most cases, **dropping in a new model is literally just
replacing the file.**

## 1. Replace the model file

Put your trained, INT8-quantized model at:

```
assets/models/deepshield_int8.tflite
```

Delete `assets/models/PLACEHOLDER_README.txt` once you've added it.

If you want a different filename or a different asset path, change
the single constant in `lib/services/deepfake_detection_service.dart`:

```dart
DeepfakeDetectionService({
  this.modelAssetPath = 'assets/models/deepshield_int8.tflite', // <- here
});
```

...or update the default and construct the service with a custom path
in `lib/app.dart`.

## 2. What the app assumes about your model

| Aspect | Assumption | Where it's read from |
|---|---|---|
| Input shape | `[1, height, width, channels]` (channels = 1 or 3) | `interpreter.getInputTensor(0).shape` — read automatically, no hardcoded size |
| Input dtype | `int8` or `uint8` | `interpreter.getInputTensor(0).type` |
| Input quantization | Pixels normalized to `[0,1]`, then quantized with the model's own `scale`/`zeroPoint` | `interpreter.getInputTensor(0).params` |
| Output shape | Either `[1, 2]` (`[real_score, fake_score]`) or `[1, 1]` (single FAKE probability) | `interpreter.getOutputTensor(0).shape` |
| Output quantization | Dequantized with the model's own `scale`/`zeroPoint`, then softmax'd (2-class) or used directly (1-class) | `interpreter.getOutputTensor(0).params` |

Because the tensor shapes and quantization parameters are read from
the model itself, **you do not need to change any Dart code** to
plug in a differently-sized INT8 model (e.g. 128×128 vs 224×224), as
long as it follows one of the two output layouts above.

## 3. If your output layout is different

If your model's output doesn't match either layout above (for
example, it returns raw logits, or more than 2 classes), you only
need to touch one method: `_interpretOutput()` in
`deepfake_detection_service.dart`. Everything upstream (preprocessing,
inference, timing) stays the same.

## 4. Converting a Keras/PyTorch model to INT8 TFLite

A typical full-integer post-training quantization step (TensorFlow):

```python
import tensorflow as tf

def representative_dataset():
    for image in calibration_images:  # ~100-500 representative samples
        yield [image]

converter = tf.lite.TFLiteConverter.from_saved_model("saved_model_dir")
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset = representative_dataset
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.int8   # or tf.uint8
converter.inference_output_type = tf.int8  # or tf.uint8

tflite_model = converter.convert()
with open("deepshield_int8.tflite", "wb") as f:
    f.write(tflite_model)
```

The resulting file's embedded quantization metadata is exactly what
`DeepfakeDetectionService` reads at runtime — no extra config needed
on the Flutter side.

## 5. Gradle: keeping the model uncompressed

`android/app/build.gradle` already sets:

```groovy
aaptOptions {
    noCompress "tflite"
}
```

This is required so the interpreter can memory-map the file directly
instead of Android decompressing it into memory first. If you rename
the asset to a different extension, update this line to match.
