import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/demo_scaffold.dart';
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
          const _GalleryHeader(
            title: 'Catatan Tahapan',
            subtitle:
                'Kumpulan catatan perbandingan dan klasifikasi dari setiap tahap pembelajaran state management dan architecture.',
          ),
          gap(),

          // ===== KLASIFIKASI =====
          _SectionDivider(
            tahap: 'Overview',
            title: 'Klasifikasi State Aplikasi',
            description:
                'Ringkasan semua state yang ada di aplikasi dan bagaimana masing-masing dikelola.',
          ),
          const StateClassificationCard(),
          gap(),

          // ===== TAHAP 2 =====
          _SectionDivider(
            tahap: 'Tahap 2',
            title: 'Prop Drilling',
            description:
                'Catatan tentang masalah prop drilling saat state harus di-passing lewat banyak layer.',
          ),
          const PropDrillingNoteCard(),
          gap(),

          // ===== TAHAP 3 =====
          _SectionDivider(
            tahap: 'Tahap 3',
            title: 'Lifting State Up',
            description:
                'Catatan tentang mengangkat state ke ancestor terdekat dan Single Source of Truth.',
          ),
          const LiftingStateUpNoteCard(),
          gap(),

          // ===== TAHAP 4 =====
          _SectionDivider(
            tahap: 'Tahap 4',
            title: 'setState vs ValueNotifier',
            description:
                'Perbandingan antara setState (local state) dengan ValueNotifier (pola listener).',
          ),
          const ValueNotifierComparisonCard(),
          gap(),

          // ===== TAHAP 5 =====
          _SectionDivider(
            tahap: 'Tahap 5',
            title: 'ValueNotifier vs ChangeNotifier',
            description:
                'Perbandingan antara ValueNotifier (satu nilai) dengan ChangeNotifier (banyak field + logika).',
          ),
          const ChangeNotifierComparisonCard(),
          gap(),

          // ===== TAHAP 6 =====
          _SectionDivider(
            tahap: 'Tahap 6',
            title: 'Provider Terpasang',
            description:
                'Status dan detail Provider yang terpasang di widget tree.',
          ),
          const ProviderStatusCard(),
          gap(),

          // ===== TAHAP 7 =====
          _SectionDivider(
            tahap: 'Tahap 7',
            title: 'Pola Akses Provider',
            description:
                'Perbandingan watch, read, Consumer, dan ListenableBuilder.',
          ),
          const ProviderPatternsComparisonCard(),
          gap(),

          // ===== TAHAP 8 =====
          _SectionDivider(
            tahap: 'Tahap 8',
            title: 'Map vs Model Course',
            description:
                'Perbandingan akses data lewat Map<String, dynamic> vs object bertipe Course.',
          ),
          const CourseModelComparisonCard(),
          gap(),

          // ===== TAHAP 9 =====
          _SectionDivider(
            tahap: 'Tahap 9',
            title: 'UI Baca JSON vs UI Panggil Service',
            description:
                'Perbandingan sebelum dan sesudah pemisahan data access ke CourseService.',
          ),
          const CourseServiceComparisonCard(),
          gap(),

          // ===== TAHAP 10 =====
          _SectionDivider(
            tahap: 'Tahap 10',
            title: 'Service vs Repository',
            description:
                'Perbandingan peran CourseService dengan CourseRepository sebagai abstraksi data.',
          ),
          const CourseRepositoryComparisonCard(),
          gap(),

          // ===== TAHAP 11 =====
          _SectionDivider(
            tahap: 'Tahap 11',
            title: 'FutureBuilder vs Provider Async State',
            description:
                'Perbandingan antara FutureBuilder ad-hoc dengan provider yang mengelola async state terpusat.',
          ),
          const AsyncStateComparisonCard(),
          gap(),

          // ===== PENUTUP =====
          _GalleryFooter(),
        ]),
      );
}

// ===== WIDGET PEMBANTU =====
// (Sama seperti di demo_gallery_page.dart — kita bisa duplikat atau pindahkan ke shared widget.
// Untuk sekarang, duplikat supaya halaman ini mandiri.)

class _GalleryHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _GalleryHeader({required this.title, required this.subtitle});

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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.menu_book_outlined,
                color: AppColors.gold, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: ts(18, w: FontWeight.bold, color: Colors.black)),
            ),
          ]),
          gap(10),
          Text(subtitle,
              style: ts(12, color: Colors.black54, height: 1.5)),
        ]),
      );
}

class _SectionDivider extends StatelessWidget {
  final String tahap;
  final String title;
  final String description;

  const _SectionDivider({
    required this.tahap,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.goldSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(color: AppColors.gold, width: 4),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(tahap,
                  style: ts(10, w: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: ts(14, w: FontWeight.bold, color: Colors.black)),
            ),
          ]),
          gap(6),
          Text(description,
              style: ts(11, color: Colors.black54, height: 1.4)),
        ]),
      );
}

class _GalleryFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.lightbulb_outline,
              color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kesimpulan',
                    style: ts(14, w: FontWeight.bold, color: Colors.black)),
                gap(4),
                Text(
                  'Setiap tahap memperkenalkan konsep baru yang menyempurnakan tahap sebelumnya — dari local state, listener, provider, hingga architecture terpisah.',
                  style: ts(11, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
        ]),
      );
}