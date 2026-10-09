import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/demo_scaffold.dart';
import '../widgets/identity_card.dart';
import 'course_detail_page.dart';

const _filterOptions = <(String, String, IconData)>[
  ('all', 'Semua', Icons.apps),
  ('done', 'Selesai', Icons.check_circle),
  ('active', 'Berjalan', Icons.play_circle),
  ('planned', 'Belum', Icons.schedule),
  ('favorite', 'Favorite', Icons.star),
];

bool _matchesFilter(String filter, Course c, Set<String> favs) =>
    switch (filter) {
      'done' || 'active' || 'planned' => c.status == filter,
      'favorite' => favs.contains(c.code),
      _ => true,
    };

bool _matchesSearch(String query, Course c) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return c.title.toLowerCase().contains(q) ||
      c.code.toLowerCase().contains(q);
}

class CourseGridPage extends StatefulWidget {
  final bool standalone;

  const CourseGridPage({super.key, this.standalone = false});

  @override
  State<CourseGridPage> createState() => _CourseGridPageState();
}

class _CourseGridPageState extends State<CourseGridPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return DemoScaffold(
      body: Column(children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: IdentityCard(
            subtitle: 'Pendidikan Teknik Informatika • Semester 5',
          ),
        ),

        _SearchBar(
          controller: _searchController,
          query: _searchQuery,
          onChanged: _onSearchChanged,
          onClear: _clearSearch,
        ),

        const _FilterBar(),

        Expanded(child: _body(context, provider)),
      ]),
    );
  }

  Widget _body(BuildContext context, CourseProvider provider) {
    if (provider.isLoading && !provider.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && !provider.hasLoaded) {
      return _errorState(provider.error!);
    }

    final favs = provider.favorites;

    final filtered = provider.courses
        .where((c) => _matchesFilter(courseFilter.value, c, favs))
        .where((c) => _matchesSearch(_searchQuery, c))
        .toList();

    if (filtered.isEmpty) {
      return _emptyState(
        query: _searchQuery,
        filter: courseFilter.value,
      );
    }

    return _grid(context, filtered, provider);
  }

  Widget _errorState(String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            gap(10),
            Text('Gagal memuat data',
                style: ts(15, w: FontWeight.bold, color: Colors.red)),
            gap(6),
            hint(message),
            gap(16),
            ElevatedButton.icon(
              onPressed: () => context.read<CourseProvider>().refresh(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba Lagi'),
              style: filled(AppColors.primary, pad: 10),
            ),
          ]),
        ),
      );

  Widget _emptyState({required String query, required String filter}) {
    final isSearching = query.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            isSearching ? Icons.search_off : Icons.filter_alt_off,
            size: 48,
            color: AppColors.muted,
          ),
          gap(10),
          Text(
            isSearching
                ? 'Tidak ada course cocok dengan pencarian.'
                : 'Tidak ada course dengan filter ini.',
            style: ts(13, w: FontWeight.w600, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          if (isSearching) ...[
            gap(6),
            hint('Kata kunci: "$query"'),
          ],
        ]),
      ),
    );
  }

  Widget _grid(
    BuildContext context,
    List<Course> items,
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
            final code = course.code;
            return CourseCard(
              course: course,
              isFavorite: provider.isFavorite(code),
              onTap: () => openCourse(context, course),
              onLongPress: () => _confirmRemove(context, course),
              onToggleFavorite: () {
                context.read<CourseProvider>().toggleFavorite(code);
              },
            );
          },
        ),
      );

  Future<void> _confirmRemove(BuildContext context, Course course) async {
    final provider = context.read<CourseProvider>();
    if (!provider.isFavorite(course.code)) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Favorite?'),
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
    provider.toggleFavorite(course.code);
    showMsg(context, 'Dihapus dari favorite.', color: Colors.red);
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: ts(13, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Cari course berdasarkan judul atau kode...',
            hintStyle: ts(12, color: Colors.black45),
            prefixIcon: const Icon(Icons.search,
                color: AppColors.primary, size: 20),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        color: AppColors.muted, size: 18),
                    onPressed: onClear,
                    tooltip: 'Bersihkan pencarian',
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.primary, width: 1.5),
            ),
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