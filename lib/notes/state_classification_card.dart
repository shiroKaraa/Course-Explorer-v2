import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/app_card.dart';

class StateClassificationCard extends StatelessWidget {
  const StateClassificationCard({super.key});

  static const _items = <(String, String, String, String)>[
    (
      'Tab aktif MainShellPage',
      'Local',
      'Hanya dipakai MainShellPage untuk memilih IndexedStack.',
      'setState()',
    ),
    (
      'Progress MiniQuiz',
      'Local',
      'Hanya relevan selama user mengerjakan quiz.',
      'setState()',
    ),
    (
      'Show/hide deskripsi CourseCard',
      'Local',
      'Setiap kartu punya preferensi buka/tutup sendiri.',
      'setState()',
    ),
    (
      'Show full description di CourseDetailPage',
      'Local',
      'Hanya mengatur tampilan satu halaman detail.',
      'setState()',
    ),
    (
      'Favorites (Set<String>) — CourseProvider',
      'Shared',
      'Dipakai di Courses, Favorites, Profile, Detail, dan Demo. Single source of truth.',
      'ChangeNotifier',
    ),
    (
      'Quiz score & course filter',
      'Shared',
      'Quiz score tampil di Profile; filter dipakai CourseGridPage.',
      'ValueNotifier',
    ),
    (
      '_favoriteCount di HomeDashboardPageV3',
      'Local (SSOT)',
      'Contoh Single Source of Truth dengan setState + callback.',
      'setState()',
    ),
    (
      'favoriteCounter (ValueNotifier<int>)',
      'Shared',
      'Pola listener sederhana (Tahap 4).',
      'ValueNotifier',
    ),
    (
      'Provider terpasang di widget tree',
      'Infrastruktur',
      'ChangeNotifierProvider membungkus MaterialApp.',
      'provider',
    ),
    (
      'Akses provider via context',
      'Infrastruktur',
      'watch untuk listen + rebuild, read untuk aksi, Consumer untuk rebuild terbatas.',
      'provider',
    ),
    (
      'Model Course',
      'Representasi data',
      'Mengubah Map<String, dynamic> menjadi object bertipe.',
      'Course.fromJson',
    ),
    (
      'CourseService',
      'Data access',
      'Membaca asset JSON dan mengembalikan List<Course>.',
      'rootBundle + Course.fromJson',
    ),
    (
      'CourseRepository',
      'Abstraksi data',
      'Kontrak + implementasi yang membungkus CourseService.',
      'abstract + impl',
    ),
    (
      'courses, isLoading, error di CourseProvider',
      'Async state',
      'Satu state holder untuk loading, error, dan data.',
      'ChangeNotifier + notifyListeners',
    ),
  ];

  Color _colorFor(String kind) {
    if (kind.startsWith('Shared')) return AppColors.success;
    if (kind.startsWith('Infrastruktur')) return AppColors.primary;
    if (kind.startsWith('Representasi')) return AppColors.warn;
    if (kind.startsWith('Data access')) return AppColors.muted;
    if (kind.startsWith('Abstraksi')) return AppColors.success;
    if (kind.startsWith('Async')) return AppColors.primary;
    if (kind.contains('SSOT')) return AppColors.warn;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.primary.withValues(alpha: 0.3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.account_tree_outlined,
            'Klasifikasi State Aplikasi',
            Text('${_items.length} state',
                style: ts(12, color: Colors.black54)),
          ),
          gap(10),
          hint(
              'Local = cukup setState di widget sendiri. Shared = dipakai banyak widget/screen.'),
          gap(10),
          for (var i = 0; i < _items.length; i++) ...[
            _row(_items[i]),
            if (i < _items.length - 1) const Divider(height: 16),
          ],
        ]),
      );

  Widget _row((String, String, String, String) item) {
    final (name, kind, reason, tool) = item;
    final c = _colorFor(kind);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(kind, style: ts(10, w: FontWeight.bold, color: c)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(name,
              style: ts(13, w: FontWeight.w600, color: Colors.black)),
        ),
      ]),
      const SizedBox(height: 4),
      Text(reason, style: ts(11, color: Colors.black54, height: 1.4)),
      const SizedBox(height: 4),
      Text('Dikelola dengan: $tool',
          style: ts(11, italic: FontStyle.italic, color: AppColors.muted)),
    ]);
  }
}