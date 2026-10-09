import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/app_card.dart';

class CourseServiceComparisonCard extends StatelessWidget {
  const CourseServiceComparisonCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.muted.withValues(alpha: 0.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.swap_horiz,
            'UI Baca JSON vs UI Panggil Service',
            Text('Tahap 9', style: ts(12, color: Colors.black54)),
            color: AppColors.muted,
          ),
          gap(10),
          _row('Tahu path file JSON?', 'Ya, di main.dart',
              'Tidak, hanya di service'),
          _row('Melakukan jsonDecode?', 'Ya, di main.dart',
              'Tidak, di service'),
          _row('Casting ke Map/List?', 'Ya, di main.dart',
              'Tidak, dari service'),
          _row('Return type', 'Future<Json>', 'Future<List<Course>>'),
          _row('Ganti sumber data', 'Ubah di main.dart',
              'Ubah di service saja'),
          _row('Test service', 'Tidak bisa lepas dari widget',
              'Bisa, murni Dart + asset'),
          gap(6),
          hint(
              'Kesimpulan: service memisahkan detail teknis data access dari UI.'),
        ]),
      );

  Widget _row(String label, String before, String after) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(11, w: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(
              child: Text('Sebelum: $before',
                  style: ts(11, color: AppColors.warn, height: 1.3)),
            ),
            Expanded(
              child: Text('Sesudah: $after',
                  style: ts(11, color: AppColors.success, height: 1.3)),
            ),
          ]),
        ]),
      );
}