import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import 'app_card.dart';

class DebugMountedDemo extends StatefulWidget {
  const DebugMountedDemo({super.key});

  @override
  State<DebugMountedDemo> createState() => _DebugMountedDemoState();
}

class _DebugMountedDemoState extends State<DebugMountedDemo> {
  String _status = 'idle';

  Future<void> _startAsyncTask() async {
    setState(() => _status = 'loading');

    // Simulasi operasi async 3 detik.
    await Future.delayed(const Duration(seconds: 3));

    // SENGAJA SALAH: tidak cek mounted.
    // Kalau widget sudah di-dispose, setState() akan memicu error.
    setState(() => _status = 'done');
  }

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            cardHeader(
              Icons.bug_report_outlined,
              'Debug: mounted check',
              Text('Tahap 15', style: ts(12, color: Colors.black54)),
              color: AppColors.warn,
            ),
            gap(10),
            hint(
                'Tekan tombol, lalu segera pindah tab sebelum 3 detik. Perhatikan error di console.'),
            gap(10),
            Text('Status: $_status', style: ts(13)),
            gap(10),
            ElevatedButton(
              onPressed: _startAsyncTask,
              style: filled(AppColors.primary),
              child: const Text('Mulai Async Task (3 detik)'),
            ),
          ],
        ),
      );
}