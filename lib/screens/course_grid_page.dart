import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';        
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../widgets/course_card.dart';
import '../widgets/demo_scaffold.dart';
import '../widgets/identity_card.dart';

const _filterOptions = <(String, String, IconData)>[
  ('all', 'Semua', Icons.apps),
  ('done', 'Selesai', Icons.check_circle),
  ('active', 'Berjalan', Icons.play_circle),
  ('planned', 'Belum', Icons.schedule),
  ('favorite', 'Favorite', Icons.star),
];

bool _matchesFilter(String filter, Json c, Set<String> favs) =>
    switch (filter) {
      'done' || 'active' || 'planned' => c.status == filter,
      'favorite' => favs.contains(c.code),
      _ => true,
    };

class CourseGridPage extends StatelessWidget {
  final bool standalone;

  const CourseGridPage({super.key, this.standalone = false});

  @override
  Widget build(BuildContext context) {
    final content = withCourses((data, courses) {
      final s = (data['student'] as Json?) ?? {};
      return Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: IdentityCard(
            name: s['name'] ?? studentName,
            nim: s['nim'] ?? studentId,
            subtitle:
                '${s['program'] ?? 'Mahasiswa'} • Semester ${s['semester'] ?? '-'}',
          ),
        ),
        const _FilterBar(),
        Expanded(
          child: ListenableBuilder(
            listenable: Listenable.merge([favorites, courseFilter]),
            builder: (_, __) {
              final favs = favorites.value;
              final filtered = courses
                  .where((c) => _matchesFilter(courseFilter.value, c, favs))
                  .toList();
              return filtered.isEmpty ? _emptyState() : _grid(filtered, favs);
            },
          ),
        ),
      ]);
    });
    return standalone ? DemoScaffold(body: content) : content;
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.filter_alt_off, size: 48, color: AppColors.muted),
            gap(10),
            hint('Tidak ada course dengan filter ini.'),
          ]),
        ),
      );

  Widget _grid(List<Json> items, Set<String> favs) => LayoutBuilder(
        builder: (context, c) => GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnsFor(c.maxWidth),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 170,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => CourseCard(
            course: items[i],
            isFavorite: favs.contains(items[i].code),
            onTap: () => openCourse(context, items[i]),
            onLongPress: () => confirmRemoveFavorite(context, items[i]),
          ),
        ),
      );
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: courseFilter,
        builder: (_, active, __) => SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: _filterOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final (key, label, icon) = _filterOptions[i];
              final selected = active == key;
              return ChoiceChip(
                selected: selected,
                onSelected: (_) => courseFilter.value = key,
                avatar: Icon(icon,
                    size: 16,
                    color: selected ? Colors.white : AppColors.primary),
                label: Text(label),
                labelStyle: ts(12,
                    w: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black87),
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              );
            },
          ),
        ),
      );
}