import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../models/course.dart';
import '../services/course_service.dart';
import '../widgets/app_card.dart';
import '../widgets/status_helper.dart';

class CourseModelDemoCard extends StatelessWidget {
  const CourseModelDemoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.warn.withValues(alpha: 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.data_object,
          'Model Course',
          Text('Tahap 8', style: ts(12, color: Colors.black54)),
          color: AppColors.warn,
        ),
        gap(10),
        hint(
            'Data JSON diubah menjadi object Course lewat Course.fromJson(). Data diambil melalui CourseService.'),
        gap(12),
        FutureBuilder<List<Course>>(
          future: courseService.loadCourses(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError || snap.data == null || snap.data!.isEmpty) {
              return Text('Gagal memuat data: ${snap.error}',
                  style: const TextStyle(color: Colors.red));
            }
            final course = snap.data!.first;
            return _coursePreview(course);
          },
        ),
      ]),
    );
  }

  Widget _coursePreview(Course course) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.school_outlined,
                size: 20, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ts(14, w: FontWeight.bold, color: Colors.black)),
            ),
            StatusHelper.badge(course.status),
          ]),
          gap(6),
          Text(course.summary, style: ts(12, color: Colors.black54)),
          gap(8),
          _row('Code (String)', course.code),
          _row('Title (String)', course.title),
          _row('Credits (int)', '${course.credits}'),
          _row('Status (String)', course.status),
          _row('Dosen (String)', course.dosen),
          gap(6),
          Row(children: [
            const Icon(Icons.check_circle_outline,
                size: 14, color: AppColors.success),
            const SizedBox(width: 6),
            Text('isDone: ${course.isDone}',
                style: ts(11, color: Colors.black87)),
            const SizedBox(width: 12),
            Text('progress: ${(course.progress * 100).round()}%',
                style: ts(11, color: Colors.black87)),
          ]),
        ]),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          Expanded(
            flex: 4,
            child: Text(label, style: ts(11, color: Colors.black54)),
          ),
          Expanded(
            flex: 6,
            child: Text(value,
                overflow: TextOverflow.ellipsis,
                style: ts(11, w: FontWeight.w600, color: Colors.black87)),
          ),
        ]),
      );
}

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