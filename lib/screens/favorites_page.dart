import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/demo_scaffold.dart';
import 'course_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  final bool standalone;

  const FavoritesPage({super.key, this.standalone = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final favCodes = provider.favorites;

    final content = withCourses((_, courses) {
      final favCourses =
          courses.where((c) => favCodes.contains(c.code)).toList();

      return Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: _SummaryHeader(count: favCourses.length),
        ),
        Expanded(
          child: favCourses.isEmpty
              ? _emptyState()
              : _grid(context, favCourses, provider),
        ),
      ]);
    });

    return standalone ? DemoScaffold(body: content) : content;
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.star_border, size: 64, color: AppColors.muted),
            gap(12),
            Text('Belum ada course favorite',
                style: ts(15, w: FontWeight.bold, color: Colors.black87)),
            gap(6),
            hint(
                'Tambahkan course ke favorite dari tab Courses atau dari halaman detail.'),
          ]),
        ),
      );

  Widget _grid(
    BuildContext context,
    List<Json> items,
    CourseProvider provider,
  ) =>
      LayoutBuilder(
        builder: (context, c) => GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnsFor(c.maxWidth),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 180,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final course = items[i];
            return CourseCard(
              course: course,
              isFavorite: true,
              onTap: () => go(context, CourseDetailPage(course: course)),
              onLongPress: () => _confirmRemove(context, course),
              onToggleFavorite: () => _confirmRemove(context, course),
            );
          },
        ),
      );

  Future<void> _confirmRemove(BuildContext context, Json course) async {
    final code = course.code;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus dari Favorite?'),
        content: Text(
            'Hapus "${course.str('title', 'Course')}" dari daftar favorite?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    context.read<CourseProvider>().toggleFavorite(code);
    showMsg(context, 'Dihapus dari favorite.', color: Colors.red);
  }
}

class _SummaryHeader extends StatelessWidget {
  final int count;
  const _SummaryHeader({required this.count});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withValues(alpha: 0.12),
              AppColors.successSoft,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
        ),
        child: Row(children: [
          const Icon(Icons.star, color: AppColors.success, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Course Favorite Saya',
                    style: ts(16, w: FontWeight.bold, color: Colors.black)),
                gap(4),
                Text('$count course',
                    style: ts(12, color: Colors.black54)),
              ],
            ),
          ),
        ]),
      );
}