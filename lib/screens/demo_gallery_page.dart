import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/demo_scaffold.dart';
import '../widgets/gallery_widgets.dart';
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
          const GalleryHeader(
            title: 'Demo Tahap 2–11',
            subtitle:
                'Kumpulan kartu demo yang menunjukkan perjalanan pembelajaran state management dan architecture.',
            icon: Icons.collections_bookmark_outlined,
            color: AppColors.primary,
          ),
          gap(),

          // ===== TAHAP 2–3 =====
          const GallerySectionDivider(
            tahap: 'Tahap 2–3',
            title: 'Prop Drilling & Lifting State Up',
            description:
                'Membuktikan masalah prop drilling dan solusinya dengan mengangkat state ke ancestor terdekat (Single Source of Truth).',
            color: AppColors.primary,
          ),
          const HomeDashboardPageV3(),
          gap(),

          // ===== TAHAP 4 =====
          const GallerySectionDivider(
            tahap: 'Tahap 4',
            title: 'ValueNotifier & ValueListenableBuilder',
            description:
                'Pola listener sederhana: satu nilai yang bisa didengarkan banyak widget tanpa constructor atau callback.',
            color: AppColors.primary,
          ),
          const HomeDashboardPageV4(),
          gap(),

          // ===== TAHAP 5–7 =====
          const GallerySectionDivider(
            tahap: 'Tahap 5–7',
            title: 'ChangeNotifier, Provider, watch/read/Consumer',
            description:
                'ChangeNotifier sebagai state holder, Provider sebagai dependency injection, dan tiga pola akses context: watch, read, Consumer.',
            color: AppColors.primary,
          ),
          const ChangeNotifierDemoCard(),
          gap(),
          const WatchReadConsumerDemoCard(),
          gap(),

          // ===== TAHAP 8 =====
          const GallerySectionDivider(
            tahap: 'Tahap 8',
            title: 'Model Course',
            description:
                'Mengubah Map<String, dynamic> menjadi object bertipe Course dengan field dan getter yang jelas.',
            color: AppColors.warn,
          ),
          const CourseModelDemoCard(),
          gap(),

          // ===== TAHAP 9 =====
          const GallerySectionDivider(
            tahap: 'Tahap 9',
            title: 'CourseService — Data Source',
            description:
                'Memisahkan detail teknis data access (rootBundle, jsonDecode) dari UI.',
            color: AppColors.muted,
          ),
          const CourseServiceDemoCard(),
          gap(),

          // ===== TAHAP 10 =====
          const GallerySectionDivider(
            tahap: 'Tahap 10',
            title: 'CourseRepository — Abstraksi Data',
            description:
                'Kontrak sumber data yang memisahkan "apa yang diminta" dari "bagaimana cara mendapatkannya".',
            color: AppColors.success,
          ),
          const CourseRepositoryDemoCard(),
          gap(),

          // ===== TAHAP 11 =====
          const GallerySectionDivider(
            tahap: 'Tahap 11',
            title: 'Provider untuk Async State',
            description:
                'Mengelola loading, error, dan success dalam satu state holder CourseProvider.',
            color: AppColors.primary,
          ),
          const AsyncCoursesCard(),
          gap(),

          // ===== PENUTUP =====
          const GalleryFooter(
            title: 'Selesai',
            description:
                'Semua tahap telah melalui proses pengembangan bertahap dari local state hingga architecture terpisah.',
            icon: Icons.emoji_events_outlined,
            color: AppColors.gold,
          ),
        ]),
      );
}