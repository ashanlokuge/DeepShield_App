No .tflite model is bundled in this template (binary model weights
can't be generated here).

Put your real, trained INT8 model at:

    assets/models/deepshield_int8.tflite

(delete this text file once you've added it — it's here only so the
assets/models/ folder isn't empty in version control)

See MODEL_INTEGRATION.md at the project root for exactly what the
model needs to look like (input/output shapes, quantization) and how
to point the app at a differently-named file if needed.
