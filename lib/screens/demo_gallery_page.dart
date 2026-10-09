import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/demo_scaffold.dart';
import '../widgets/scroll_page.dart';

// Import semua kartu demo
import '../demos/tahap_2_3_demo.dart';
import '../demos/tahap_4_demo.dart';
import '../demos/tahap_5_6_7_demo.dart';
import '../demos/tahap_8_demo.dart';
import '../demos/tahap_9_demo.dart';
import '../demos/tahap_10_demo.dart';
import '../demos/tahap_11_demo.dart';

class DemoGalleryPage extends StatelessWidget {
  const DemoGalleryPage({super.key});

  @override
  Widget build(BuildContext context) => DemoScaffold(
        body: ScrollPage([
          const _GalleryHeader(
            title: 'Demo Tahap 2–11',
            subtitle:
                'Kumpulan kartu demo yang menunjukkan perjalanan pembelajaran state management dan architecture.',
          ),
          gap(),

          // ===== TAHAP 2–3 =====
          _SectionDivider(
            tahap: 'Tahap 2–3',
            title: 'Prop Drilling & Lifting State Up',
            description:
                'Membuktikan masalah prop drilling dan solusinya dengan mengangkat state ke ancestor terdekat (Single Source of Truth).',
          ),
          const HomeDashboardPageV3(),
          gap(),

          // ===== TAHAP 4 =====
          _SectionDivider(
            tahap: 'Tahap 4',
            title: 'ValueNotifier & ValueListenableBuilder',
            description:
                'Pola listener sederhana: satu nilai yang bisa didengarkan banyak widget tanpa constructor atau callback.',
          ),
          const HomeDashboardPageV4(),
          gap(),

          // ===== TAHAP 5–7 =====
          _SectionDivider(
            tahap: 'Tahap 5–7',
            title: 'ChangeNotifier, Provider, watch/read/Consumer',
            description:
                'ChangeNotifier sebagai state holder, Provider sebagai dependency injection, dan tiga pola akses context: watch, read, Consumer.',
          ),
          const ChangeNotifierDemoCard(),
          gap(),
          const WatchReadConsumerDemoCard(),
          gap(),

          // ===== TAHAP 8 =====
          _SectionDivider(
            tahap: 'Tahap 8',
            title: 'Model Course',
            description:
                'Mengubah Map<String, dynamic> menjadi object bertipe Course dengan field dan getter yang jelas.',
          ),
          const CourseModelDemoCard(),
          gap(),

          // ===== TAHAP 9 =====
          _SectionDivider(
            tahap: 'Tahap 9',
            title: 'CourseService — Data Source',
            description:
                'Memisahkan detail teknis data access (rootBundle, jsonDecode) dari UI.',
          ),
          const CourseServiceDemoCard(),
          gap(),

          // ===== TAHAP 10 =====
          _SectionDivider(
            tahap: 'Tahap 10',
            title: 'CourseRepository — Abstraksi Data',
            description:
                'Kontrak sumber data yang memisahkan "apa yang diminta" dari "bagaimana cara mendapatkannya".',
          ),
          const CourseRepositoryDemoCard(),
          gap(),

          // ===== TAHAP 11 =====
          _SectionDivider(
            tahap: 'Tahap 11',
            title: 'Provider untuk Async State',
            description:
                'Mengelola loading, error, dan success dalam satu state holder CourseProvider.',
          ),
          const AsyncCoursesCard(),
          gap(),

          // ===== PENUTUP =====
          _GalleryFooter(),
        ]),
      );
}

// ===== WIDGET PEMBANTU =====

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
              AppColors.primary.withValues(alpha: 0.12),
              AppColors.primarySoft,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.collections_bookmark_outlined,
                color: AppColors.primary, size: 28),
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
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(color: AppColors.primary, width: 4),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
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
          color: AppColors.goldSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          const Icon(Icons.emoji_events_outlined,
              color: AppColors.gold, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selesai',
                    style: ts(14, w: FontWeight.bold, color: Colors.black)),
                gap(4),
                Text(
                  'Semua tahap telah melalui proses pengembangan bertahap dari local state hingga architecture terpisah.',
                  style: ts(11, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
        ]),
      );
}