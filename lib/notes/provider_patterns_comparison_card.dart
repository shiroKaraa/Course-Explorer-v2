import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/app_card.dart';

class ProviderPatternsComparisonCard extends StatelessWidget {
  const ProviderPatternsComparisonCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.primary.withValues(alpha: 0.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.visibility_outlined,
            'Pola Akses Provider',
            Text('Tahap 7', style: ts(12, color: Colors.black54)),
            color: AppColors.primary,
          ),
          gap(10),
          _row(
            'context.watch<T>()',
            'Listen + rebuild widget',
            'Menampilkan nilai di UI',
            AppColors.primary,
          ),
          _row(
            'context.read<T>()',
            'Ambil instance, tanpa listen',
            'Memanggil method / aksi tombol',
            AppColors.warn,
          ),
          _row(
            'Consumer<T>',
            'Listen + rebuild terbatas',
            'Membatasi rebuild ke area kecil',
            AppColors.success,
          ),
          _row(
            'ListenableBuilder',
            'Listen ke Listenable apa pun',
            'Alternatif tanpa Provider',
            AppColors.muted,
          ),
          gap(6),
          hint(
              'Aturan singkat: watch untuk tampilkan, read untuk aksi, Consumer untuk area kecil yang sering berubah. Jangan panggil watch di dalam onPressed.'),
        ]),
      );

  Widget _row(String label, String behavior, String useCase, Color color) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(label,
                  style: ts(10, w: FontWeight.bold, color: color)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(behavior,
              style: ts(11, w: FontWeight.w600, color: Colors.black87)),
          Text(useCase, style: ts(11, color: Colors.black54, height: 1.3)),
        ]),
      );
}