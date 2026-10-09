import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../providers/course_provider.dart';
import '../widgets/app_card.dart';

// ===== TAHAP 6 =====
class ChangeNotifierDemoCard extends StatelessWidget {
  const ChangeNotifierDemoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.primary.withValues(alpha: 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.sync_alt,
          'ChangeNotifier via Provider',
          Text('Tahap 6', style: ts(12, color: Colors.black54)),
          color: AppColors.primary,
        ),
        gap(10),
        hint(
            'Kartu ini memakai context.watch<CourseProvider>() untuk menampilkan jumlah favorite. Setiap notifyListeners() memicu rebuild otomatis.'),
        gap(12),
        _counterRow(provider),
        gap(10),
        _courseToggleList(context, provider),
        gap(10),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.read<CourseProvider>().clearFavorites(),
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Reset'),
              style: outlined(AppColors.muted, pad: 8),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _counterRow(CourseProvider provider) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          const Icon(Icons.star, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Jumlah favorite: ', style: ts(12, color: Colors.black87)),
          Text('${provider.favoriteCount}',
              style: ts(16, w: FontWeight.bold, color: AppColors.primary)),
          const Spacer(),
          hint('via watch'),
        ]),
      );

  Widget _courseToggleList(BuildContext context, CourseProvider provider) =>
      withCourses(
        handleStates: false,
        (_, courses) => Column(children: [
          for (final c in courses.take(4))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () =>
                    context.read<CourseProvider>().toggleFavorite(c.code),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(children: [
                    Icon(
                      provider.isFavorite(c.code)
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: provider.isFavorite(c.code)
                          ? AppColors.success
                          : AppColors.muted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${c.code} — ${c.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ts(12, color: Colors.black87)),
                    ),
                  ]),
                ),
              ),
            ),
        ]),
      );
}

// ===== TAHAP 7 =====
class WatchReadConsumerDemoCard extends StatelessWidget {
  const WatchReadConsumerDemoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.success.withValues(alpha: 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.visibility_outlined,
          'watch, read, dan Consumer',
          Text('Tahap 7', style: ts(12, color: Colors.black54)),
        ),
        gap(10),
        hint(
            'Tiga pola dalam satu kartu: watch untuk menampilkan nilai, read untuk aksi tombol, dan Consumer untuk membatasi rebuild ke satu area kecil.'),
        gap(12),
        _sectionLabel(
          'context.watch',
          'Widget ini (seluruh kartu) rebuild setiap provider berubah.',
          color: AppColors.primary,
        ),
        gap(6),
        _counterRow(provider),
        gap(10),
        _sectionLabel(
          'context.read',
          'Tombol di bawah hanya memanggil method, tidak listen. Tidak memicu rebuild tambahan.',
          color: AppColors.warn,
        ),
        gap(6),
        Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                final p = context.read<CourseProvider>();
                final list = p.favorites.toList()..sort();
                if (list.isEmpty) {
                  showMsg(context, 'Belum ada favorite untuk ditampilkan.');
                  return;
                }
                showMsg(
                  context,
                  'Favorite aktif: ${list.length} course',
                  color: AppColors.success,
                );
              },
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text('Cek Favorite (read)'),
              style: filled(AppColors.warn, pad: 10),
            ),
          ),
        ]),
        gap(14),
        _sectionLabel(
          'Consumer',
          'Hanya tile kecil di bawah yang rebuild, bukan seluruh kartu.',
          color: AppColors.success,
        ),
        gap(6),
        const ConsumerOnlyCounterTile(),
      ]),
    );
  }

  Widget _sectionLabel(String title, String desc, {required Color color}) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(title, style: ts(10, w: FontWeight.bold, color: color)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(desc,
              style: ts(11, color: Colors.black54, height: 1.4)),
        ),
      ]);

  Widget _counterRow(CourseProvider provider) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          const Icon(Icons.star, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Jumlah favorite: ', style: ts(12, color: Colors.black87)),
          Text('${provider.favoriteCount}',
              style: ts(16, w: FontWeight.bold, color: AppColors.primary)),
          const Spacer(),
          hint('watch'),
        ]),
      );
}

class ConsumerOnlyCounterTile extends StatelessWidget {
  const ConsumerOnlyCounterTile({super.key});

  @override
  Widget build(BuildContext context) => Consumer<CourseProvider>(
        builder: (context, provider, child) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.successSoft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
          ),
          child: Row(children: [
            const Icon(Icons.visibility, size: 18, color: AppColors.success),
            const SizedBox(width: 8),
            Text('Consumer — favorite: ',
                style: ts(12, color: Colors.black87)),
            Text('${provider.favoriteCount}',
                style: ts(16, w: FontWeight.bold, color: AppColors.success)),
            const Spacer(),
            hint('rebuild terbatas'),
          ]),
        ),
      );
}

// ===== FAVORITE SECTION (dulu di main.dart) =====
class FavoriteSectionCard extends StatelessWidget {
  const FavoriteSectionCard({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Set<String>>(
        valueListenable: favorites,
        builder: (context, favs, _) =>
            withCourses(handleStates: false, (_, courses) {
          final favCourses =
              courses.where((c) => favs.contains(c.code)).toList();
          return AppCard(
            borderColor: AppColors.success.withValues(alpha: 0.35),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              cardHeader(
                Icons.star,
                'Course Favorite (ValueNotifier)',
                Text('${favCourses.length}',
                    style:
                        ts(13, w: FontWeight.bold, color: AppColors.success)),
              ),
              gap(10),
              if (favCourses.isEmpty)
                hint('Belum ada course favorite. Tap ikon ⭐ di halaman detail course.')
              else
                for (final c in favCourses) _favItem(context, c),
            ]),
          );
        }),
      );

  Widget _favItem(BuildContext context, Json c) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => openCourse(context, c),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(children: [
              const Icon(Icons.bookmark, size: 16, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(c.title,
                    overflow: TextOverflow.ellipsis,
                    style: ts(13, w: FontWeight.w500, color: Colors.black)),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
            ]),
          ),
        ),
      );
}