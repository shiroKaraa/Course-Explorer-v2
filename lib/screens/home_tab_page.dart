import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/fade_in.dart';
import '../widgets/identity_card.dart';
import '../widgets/mini_quiz_card.dart';
import '../widgets/status_helper.dart';
import '../demos/tahap_5_6_7_demo.dart';
import '../demos/tahap_11_demo.dart';
import 'course_detail_page.dart';
import 'demo_gallery_page.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
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
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
      
          const IdentityCard(),
          gap(),

         
          const FadeIn(
            delay: Duration(milliseconds: 120),
            slideOffset: 10,
            child: _StatsCard(),
          ),
          gap(),

          
          const FadeIn(
            delay: Duration(milliseconds: 220),
            slideOffset: 10,
            child: _DemoButton(),
          ),
          gap(),

          
          const AsyncCoursesCard(),
          gap(),

         
          sectionTitle('Course Terbaru'),
          gap(8),
          const _RecentCourses(),
          gap(),

        
          const FavoriteSectionCard(),
          gap(12),

        
          const MiniQuizCard(),
        ],
      );
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final courses = provider.courses;
    final totalCourses = courses.length;
    final totalCredits =
        courses.fold<int>(0, (sum, c) => sum + c.credits);
    final favCount = provider.favoriteCount;

    return AppCard(
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cardHeader(
            Icons.insights_outlined,
            'Statistik',
            Text('Course Explorer v2', style: ts(11, color: Colors.black54)),
            color: AppColors.primary,
          ),
          gap(12),
          Row(children: [
            Expanded(
              child: _StatTile(
                icon: Icons.book_outlined,
                label: 'Course',
                value: '$totalCourses',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.school_outlined,
                label: 'Total SKS',
                value: '$totalCredits',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.star,
                label: 'Favorite',
                value: '$favCount',
                color: AppColors.gold,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: ts(18, w: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: ts(11, color: Colors.black54),
              textAlign: TextAlign.center),
        ]),
      );
}

 
class _DemoButton extends StatelessWidget {
  const _DemoButton();

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => go(context, const DemoGalleryPage()),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gold.withValues(alpha: 0.15),
                AppColors.goldSoft,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.collections_bookmark_outlined,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lihat Demo Tahap 2–11',
                      style:
                          ts(14, w: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 2),
                  Text(
                    'Perjalanan pembelajaran state management dan architecture',
                    style: ts(11, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gold, size: 24),
          ]),
        ),
      );
}

class _RecentCourses extends StatelessWidget {
  const _RecentCourses();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    if (!provider.hasLoaded) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final recent = provider.courses.take(3).toList();
    if (recent.isEmpty) {
      return AppCard(
        child: hint('Belum ada course.'),
      );
    }
    return Column(children: [
      for (final c in recent)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(StatusHelper.icon(c.status),
                  color: StatusHelper.color(c.status)),
              title: Text(c.title),
              subtitle: Text(c.summary),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openCourse(context, c),
            ),
          ),
        ),
    ]);
  }
}