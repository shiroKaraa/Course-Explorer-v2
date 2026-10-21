import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 64, color: AppColors.warn),
            gap(16),
            Text('Gagal Memuat Data',
                style: ts(16, w: FontWeight.bold, color: Colors.black87)),
            gap(8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ts(12, color: Colors.black54),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            gap(20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
              style: filled(AppColors.primary, pad: 12),
            ),
          ],
        ),
      ),
    );
  }
}