import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/app_card.dart';

class AsyncCoursesCard extends StatefulWidget {
  const AsyncCoursesCard({super.key});

  @override
  State<AsyncCoursesCard> createState() => _AsyncCoursesCardState();
}

class _AsyncCoursesCardState extends State<AsyncCoursesCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CourseProvider>();
      if (!provider.hasLoaded && !provider.isLoading) {
        provider.loadCourses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.primary.withValues(alpha: 0.6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.sync_problem_outlined,
          'Provider Async State',
          Text('Tahap 11', style: ts(12, color: Colors.black54)),
          color: AppColors.primary,
        ),
        gap(10),
        hint(
            'Provider mengelola isLoading, error, dan courses. UI menampilkan tiga kondisi tanpa FutureBuilder.'),
        gap(12),
        _body(provider),
        gap(10),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: provider.isLoading
                  ? null
                  : () {
                      context.read<CourseProvider>().refresh();
                    },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh (via provider)'),
              style: outlined(AppColors.primary, pad: 10),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _body(CourseProvider provider) {
    if (provider.isLoading) {
      return _loadingTile();
    }
    if (provider.error != null) {
      return _errorTile(provider.error!);
    }
    if (!provider.hasLoaded) {
      return _initialTile();
    }
    return _successTile(provider.courses);
  }

  Widget _initialTile() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          const Icon(Icons.hourglass_empty, size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Text('Initial: belum ada data dimuat.',
              style: ts(12, color: Colors.black87)),
        ]),
      );

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
          Text('Loading: memuat data dari provider...',
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.error_outline, size: 18, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Error dari provider',
                  style: ts(12, w: FontWeight.bold, color: Colors.red.shade700)),
            ),
          ]),
          gap(6),
          Text(message, style: ts(11, color: Colors.red.shade700)),
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
            Text('Success: ${courses.length} course',
                style: ts(12, w: FontWeight.bold, color: AppColors.success)),
            const Spacer(),
            hint('via provider'),
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

class AsyncStateIndicatorCard extends StatelessWidget {
  const AsyncStateIndicatorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        final label = provider.asyncStateLabel;
        final color = _colorFor(label);
        final icon = _iconFor(label);
        return AppCard(
          borderColor: color.withValues(alpha: 0.5),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 6),
                Text(label.toUpperCase(),
                    style: ts(10, w: FontWeight.bold, color: color)),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _descriptionFor(label),
                style: ts(12, color: Colors.black87),
              ),
            ),
            hint('Tahap 11'),
          ]),
        );
      },
    );
  }

  Color _colorFor(String label) {
    switch (label) {
      case 'loading':
        return AppColors.primary;
      case 'success':
        return AppColors.success;
      case 'error':
        return Colors.red.shade700;
      default:
        return AppColors.muted;
    }
  }

  IconData _iconFor(String label) {
    switch (label) {
      case 'loading':
        return Icons.hourglass_top;
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  String _descriptionFor(String label) {
    switch (label) {
      case 'loading':
        return 'Provider sedang memuat data dari repository.';
      case 'success':
        return 'Data course berhasil dimuat dan siap ditampilkan.';
      case 'error':
        return 'Terjadi error saat memuat data. Coba Refresh.';
      default:
        return 'Belum ada pemuatan data. Panggil loadCourses().';
    }
  }
}