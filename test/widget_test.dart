import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deepshield/app.dart';
import 'package:deepshield/models/detection_result.dart';

void main() {
  testWidgets('Home screen shows title and image source buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DeepShieldApp());

    expect(find.text('DeepShield'), findsOneWidget);
    expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    expect(find.text('Choose from Gallery'), findsOneWidget);
    expect(find.text('Take a Photo'), findsOneWidget);

    // No error banner or loading overlay before the user picks an image.
    expect(find.byIcon(Icons.error_outline), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  group('DetectionResult', () {
    test('formats a FAKE result', () {
      const result = DetectionResult(
        label: DetectionLabel.fake,
        confidence: 0.924,
        inferenceTimeMs: 42,
      );

      expect(result.isFake, isTrue);
      expect(result.labelText, 'FAKE');
      expect(result.confidencePercentText, '92.4%');
    });

    test('formats a REAL result and clamps confidence', () {
      const result = DetectionResult(
        label: DetectionLabel.real,
        confidence: 1.5,
        inferenceTimeMs: 10,
      );

      expect(result.isFake, isFalse);
      expect(result.labelText, 'REAL');
      expect(result.confidencePercentText, '100.0%');
    });

    test('copyWith replaces only the given fields', () {
      const original = DetectionResult(
        label: DetectionLabel.real,
        confidence: 0.8,
        inferenceTimeMs: 5,
      );
      final copy = original.copyWith(label: DetectionLabel.fake);

      expect(copy.label, DetectionLabel.fake);
      expect(copy.confidence, 0.8);
      expect(copy.inferenceTimeMs, 5);
    });
  });
}
