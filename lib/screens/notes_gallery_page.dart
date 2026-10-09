import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/demo_scaffold.dart';
import '../widgets/gallery_widgets.dart';
import '../widgets/scroll_page.dart';

// Import semua kartu catatan
import '../notes/state_classification_card.dart';
import '../notes/prop_drilling_note_card.dart';
import '../notes/lifting_state_up_note_card.dart';
import '../notes/value_notifier_comparison_card.dart';
import '../notes/change_notifier_comparison_card.dart';
import '../notes/provider_status_card.dart';
import '../notes/provider_patterns_comparison_card.dart';
import '../notes/course_model_comparison_card.dart';
import '../notes/course_service_comparison_card.dart';
import '../notes/course_repository_comparison_card.dart';
import '../notes/async_state_comparison_card.dart';

class NotesGalleryPage extends StatelessWidget {
  const NotesGalleryPage({super.key});

  @override
  Widget build(BuildContext context) => DemoScaffold(
        body: ScrollPage([
          const GalleryHeader(
            title: 'Catatan Tahapan',
            subtitle:
                'Kumpulan catatan perbandingan dan klasifikasi dari setiap tahap pembelajaran state management dan architecture.',
            icon: Icons.menu_book_outlined,
            color: AppColors.gold,
          ),
          gap(),

          // ===== KLASIFIKASI =====
          const GallerySectionDivider(
            tahap: 'Overview',
            title: 'Klasifikasi State Aplikasi',
            description:
                'Ringkasan semua state yang ada di aplikasi dan bagaimana masing-masing dikelola.',
            color: AppColors.gold,
          ),
          const StateClassificationCard(),
          gap(),

          // ===== TAHAP 2 =====
          const GallerySectionDivider(
            tahap: 'Tahap 2',
            title: 'Prop Drilling',
            description:
                'Catatan tentang masalah prop drilling saat state harus di-passing lewat banyak layer.',
            color: AppColors.gold,
          ),
          const PropDrillingNoteCard(),
          gap(),

          // ===== TAHAP 3 =====
          const GallerySectionDivider(
            tahap: 'Tahap 3',
            title: 'Lifting State Up',
            description:
                'Catatan tentang mengangkat state ke ancestor terdekat dan Single Source of Truth.',
            color: AppColors.gold,
          ),
          const LiftingStateUpNoteCard(),
          gap(),

          // ===== TAHAP 4 =====
          const GallerySectionDivider(
            tahap: 'Tahap 4',
            title: 'setState vs ValueNotifier',
            description:
                'Perbandingan antara setState (local state) dengan ValueNotifier (pola listener).',
            color: AppColors.gold,
          ),
          const ValueNotifierComparisonCard(),
          gap(),

          // ===== TAHAP 5 =====
          const GallerySectionDivider(
            tahap: 'Tahap 5',
            title: 'ValueNotifier vs ChangeNotifier',
            description:
                'Perbandingan antara ValueNotifier (satu nilai) dengan ChangeNotifier (banyak field + logika).',
            color: AppColors.gold,
          ),
          const ChangeNotifierComparisonCard(),
          gap(),

          // ===== TAHAP 6 =====
          const GallerySectionDivider(
            tahap: 'Tahap 6',
            title: 'Provider Terpasang',
            description:
                'Status dan detail Provider yang terpasang di widget tree.',
            color: AppColors.gold,
          ),
          const ProviderStatusCard(),
          gap(),

          // ===== TAHAP 7 =====
          const GallerySectionDivider(
            tahap: 'Tahap 7',
            title: 'Pola Akses Provider',
            description:
                'Perbandingan watch, read, Consumer, dan ListenableBuilder.',
            color: AppColors.gold,
          ),
          const ProviderPatternsComparisonCard(),
          gap(),

          // ===== TAHAP 8 =====
          const GallerySectionDivider(
            tahap: 'Tahap 8',
            title: 'Map vs Model Course',
            description:
                'Perbandingan akses data lewat Map<String, dynamic> vs object bertipe Course.',
            color: AppColors.gold,
          ),
          const CourseModelComparisonCard(),
          gap(),

          // ===== TAHAP 9 =====
          const GallerySectionDivider(
            tahap: 'Tahap 9',
            title: 'UI Baca JSON vs UI Panggil Service',
            description:
                'Perbandingan sebelum dan sesudah pemisahan data access ke CourseService.',
            color: AppColors.gold,
          ),
          const CourseServiceComparisonCard(),
          gap(),

          // ===== TAHAP 10 =====
          const GallerySectionDivider(
            tahap: 'Tahap 10',
            title: 'Service vs Repository',
            description:
                'Perbandingan peran CourseService dengan CourseRepository sebagai abstraksi data.',
            color: AppColors.gold,
          ),
          const CourseRepositoryComparisonCard(),
          gap(),

          // ===== TAHAP 11 =====
          const GallerySectionDivider(
            tahap: 'Tahap 11',
            title: 'FutureBuilder vs Provider Async State',
            description:
                'Perbandingan antara FutureBuilder ad-hoc dengan provider yang mengelola async state terpusat.',
            color: AppColors.gold,
          ),
          const AsyncStateComparisonCard(),
          gap(),

          // ===== PENUTUP =====
          const GalleryFooter(
            title: 'Kesimpulan',
            description:
                'Setiap tahap memperkenalkan konsep baru yang menyempurnakan tahap sebelumnya — dari local state, listener, provider, hingga architecture terpisah.',
            icon: Icons.lightbulb_outline,
            color: AppColors.primary,
          ),
        ]),
      );
}