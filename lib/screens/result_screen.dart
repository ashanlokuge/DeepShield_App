import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/detection_result.dart';
import '../theme/app_theme.dart';
import '../widgets/confidence_indicator.dart';
import '../widgets/primary_button.dart';

/// Shows the classification, confidence, inference time and the
/// analyzed image, plus a Share Result action using Android's
/// native share sheet.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.result,
  });

  final File imageFile;
  final DetectionResult result;

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return result.isFake ? scheme.error : AppTheme.safeColor;
  }

  Future<void> _shareResult(BuildContext context) async {
    final shareText =
        'DeepShield AI Analysis\n\n'
        'Result: ${result.labelText}\n'
        'Confidence: ${result.confidencePercentText}\n'
        'Inference time: ${result.inferenceTimeMs} ms\n\n'
        'Detected locally using an on-device lightweight AI model.';

    final box = context.findRenderObject() as RenderBox?;

    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: 'DeepShield AI Analysis Result',
        files: [XFile(imageFile.path)],
        sharePositionOrigin:
            box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Result')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.file(imageFile, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Semantics(
                  label: 'Result: ${result.labelText}',
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: statusColor, width: 1.5),
                    ),
                    child: Text(
                      result.labelText,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ConfidenceIndicator(confidence: result.confidence, color: statusColor),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Confidence: ${result.confidencePercentText}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 24),
              _InfoRow(
                icon: Icons.timer_outlined,
                label: 'Inference time',
                value: '${result.inferenceTimeMs} ms',
              ),
              const _InfoRow(
                icon: Icons.smartphone_outlined,
                label: 'Processed',
                value: 'On-device',
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Share Result',
                icon: Icons.share_outlined,
                onPressed: () => _shareResult(context),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.refresh),
                label: const Text('Analyze Another Image'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
