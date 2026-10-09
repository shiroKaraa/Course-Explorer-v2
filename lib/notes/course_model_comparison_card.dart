import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/app_card.dart';

class CourseModelComparisonCard extends StatelessWidget {
  const CourseModelComparisonCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.warn.withValues(alpha: 0.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.data_object,
            'Map vs Model Course',
            Text('Tahap 8', style: ts(12, color: Colors.black54)),
            color: AppColors.warn,
          ),
          gap(10),
          _row('Tipe data', 'Map<String, dynamic>', 'Course (class)'),
          _row('Akses field', "course['title']", 'course.title'),
          _row('Keamanan tipe', 'Runtime (bisa salah ketik)', 'Compile-time'),
          _row('Parsing', 'Manual di UI', 'Course.fromJson()'),
          _row('Helper/logic', 'Sulit (tersebar)',
              'Di dalam class (isDone, progress)'),
          _row('Refactor aman', 'Rentan typo key',
              'Rename field terbantu IDE'),
          gap(6),
          hint(
              'Kesimpulan: model memindahkan representasi data dari Map longgar ke object bertipe.'),
        ]),
      );

  Widget _row(String label, String before, String after) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(11, w: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(
              child: Text('Map: $before',
                  style: ts(11, color: AppColors.warn, height: 1.3)),
            ),
            Expanded(
              child: Text('Model: $after',
                  style: ts(11, color: AppColors.success, height: 1.3)),
            ),
          ]),
        ]),
      );
}