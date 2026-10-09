import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';
import '../widgets/app_card.dart';

class CourseRepositoryDemoCard extends StatefulWidget {
  const CourseRepositoryDemoCard({super.key});

  @override
  State<CourseRepositoryDemoCard> createState() =>
      _CourseRepositoryDemoCardState();
}

class _CourseRepositoryDemoCardState extends State<CourseRepositoryDemoCard> {
  late Future<List<Course>> _future;

  @override
  void initState() {
    super.initState();
    _future = courseRepository.getCourses();
  }

  void _reload() {
    setState(() {
      _future = courseRepository.getCourses();
    });
    showMsg(context, 'Memuat ulang data dari repository...',
        color: AppColors.success);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.success.withValues(alpha: 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.storage_outlined,
          'CourseRepository',
          Text('Tahap 10', style: ts(12, color: Colors.black54)),
        ),
        gap(10),
        hint(
            'UI memanggil courseRepository.getCourses(). Repository membungkus service; UI tidak tahu implementasi konkretnya.'),
        gap(12),
        FutureBuilder<List<Course>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return _loadingTile();
            }
            if (snap.hasError) {
              return _errorTile('${snap.error}');
            }
            final courses = snap.data ?? const <Course>[];
            return _successTile(courses);
          },
        ),
        gap(10),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Muat Ulang'),
              style: outlined(AppColors.success, pad: 10),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _loadingTile() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text('Memuat data dari repository...',
              style: ts(12, color: Colors.black87)),
        ]),
      );

  Widget _errorTile(String message) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.errorSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, size: 18, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Error: $message',
                style: ts(12, color: Colors.red.shade700)),
          ),
        ]),
      );

  Widget _successTile(List<Course> courses) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.check_circle, size: 18, color: AppColors.success),
            const SizedBox(width: 8),
            Text('Repository sukses: ${courses.length} course',
                style: ts(12, w: FontWeight.bold, color: AppColors.success)),
            const Spacer(),
            hint('via repository'),
          ]),
          gap(10),
          for (final c in courses.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Icon(Icons.storage_outlined,
                    size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('${c.code} — ${c.title} '
                      '(${c.credits} SKS)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(11, color: Colors.black87)),
                ),
              ]),
            ),
        ]),
      );
}