/// The two classification outcomes DeepShield can produce.
enum DetectionLabel { real, fake }

/// Immutable result of running the on-device deepfake detector on
/// a single image.
class DetectionResult {
  const DetectionResult({
    required this.label,
    required this.confidence,
    required this.inferenceTimeMs,
  });

  /// REAL or FAKE.
  final DetectionLabel label;

  /// Model confidence for [label], in the range [0.0, 1.0].
  final double confidence;

  /// Wall-clock time the TFLite interpreter took to run, in milliseconds.
  final int inferenceTimeMs;

  bool get isFake => label == DetectionLabel.fake;

  String get labelText => isFake ? 'FAKE' : 'REAL';

  String get confidencePercentText =>
      '${(confidence * 100).clamp(0, 100).toStringAsFixed(1)}%';

  DetectionResult copyWith({
    DetectionLabel? label,
    double? confidence,
    int? inferenceTimeMs,
  }) {
    return DetectionResult(
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      inferenceTimeMs: inferenceTimeMs ?? this.inferenceTimeMs,
    );
  }

  @override
  String toString() =>
      'DetectionResult(label: $labelText, confidence: $confidencePercentText, '
      'inferenceTimeMs: $inferenceTimeMs)';
}

/// Thrown by [DeepfakeDetectionService] for any recoverable failure
/// (bad image, model not loaded, unexpected tensor shape, etc.) so the
/// UI can show a friendly, specific error message instead of crashing.
class DeepfakeDetectionException implements Exception {
  const DeepfakeDetectionException(this.message);

  final String message;

  @override
  String toString() => message;
}
