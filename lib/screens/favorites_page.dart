import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/demo_scaffold.dart';
import 'course_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  final bool standalone;

  const FavoritesPage({super.key, this.standalone = false});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<CourseProvider>();
      if (!provider.hasLoaded && !provider.isLoading) {
        provider.loadCourses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return DemoScaffold(
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: _SummaryHeader(count: provider.favoriteCount),
        ),
        Expanded(child: _body(context, provider)),
      ]),
    );
  }

  Widget _body(BuildContext context, CourseProvider provider) {
    if (provider.isLoading && !provider.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && !provider.hasLoaded) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Gagal memuat data: ${provider.error}',
              style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final favs = provider.favorites;
    final favCourses =
        provider.courses.where((c) => favs.contains(c.code)).toList();

    if (favCourses.isEmpty) return _emptyState();
    return _grid(context, favCourses);
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

  Widget _grid(BuildContext context, List<Course> items) => LayoutBuilder(
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
              onTap: () => openCourse(context, course),
              onLongPress: () => _confirmRemove(context, course),
              onToggleFavorite: () => _confirmRemove(context, course),
            );
          },
        ),
      );

  Future<void> _confirmRemove(BuildContext context, Course course) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus dari Favorite?'),
        content: Text('Hapus "${course.title}" dari daftar favorite?'),
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
    context.read<CourseProvider>().toggleFavorite(course.code);
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
              AppColors.gold.withValues(alpha: 0.15),
              AppColors.goldSoft,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          const Icon(Icons.star, color: AppColors.gold, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Course Favorite Saya',
                    style: ts(16, w: FontWeight.bold, color: Colors.black)),
                gap(4),
                Text('$count course', style: ts(12, color: Colors.black54)),
              ],
            ),
          ),
        ]),
      );
}