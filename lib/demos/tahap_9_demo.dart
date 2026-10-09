import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../models/course.dart';
import '../services/course_service.dart';
import '../widgets/app_card.dart';

class CourseServiceDemoCard extends StatefulWidget {
  const CourseServiceDemoCard({super.key});

  @override
  State<CourseServiceDemoCard> createState() => _CourseServiceDemoCardState();
}

class _CourseServiceDemoCardState extends State<CourseServiceDemoCard> {
  late Future<List<Course>> _future;

  @override
  void initState() {
    super.initState();
    _future = courseService.loadCourses();
  }

  void _reload() {
    setState(() {
      _future = courseService.loadCourses();
    });
    showMsg(context, 'Memuat ulang data dari service...',
        color: AppColors.primary);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.muted.withValues(alpha: 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.cloud_download_outlined,
          'CourseService',
          Text('Tahap 9', style: ts(12, color: Colors.black54)),
          color: AppColors.muted,
        ),
        gap(10),
        hint(
            'UI memanggil courseService.loadCourses() dan menerima List<Course>. Path asset JSON dan parsing tersembunyi di dalam service.'),
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
              style: outlined(AppColors.muted, pad: 10),
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
          Text('Memuat data dari service...',
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
            Text('Sukses: ${courses.length} course diterima',
                style: ts(12, w: FontWeight.bold, color: AppColors.success)),
            const Spacer(),
            hint('List<Course>'),
          ]),
          gap(10),
          for (final c in courses.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Icon(Icons.school_outlined,
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