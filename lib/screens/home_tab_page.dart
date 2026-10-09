import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/identity_card.dart';
import '../widgets/mini_quiz_card.dart';
import '../widgets/status_helper.dart';
import '../demos/tahap_2_3_demo.dart';
import '../demos/tahap_4_demo.dart';
import '../demos/tahap_5_6_7_demo.dart';
import '../demos/tahap_8_demo.dart';
import '../demos/tahap_9_demo.dart';
import '../demos/tahap_10_demo.dart';
import '../demos/tahap_11_demo.dart';
import 'course_detail_page.dart';

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
          const AsyncCoursesCard(),
          gap(),
          const CourseRepositoryDemoCard(),
          gap(),
          const CourseServiceDemoCard(),
          gap(),
          const CourseModelDemoCard(),
          gap(),
          const WatchReadConsumerDemoCard(),
          gap(),
          const ChangeNotifierDemoCard(),
          gap(),
          const HomeDashboardPageV3(),
          gap(),
          const HomeDashboardPageV4(),
          gap(),
          const MiniQuizCard(),
          gap(12),
          const FavoriteSectionCard(),
          gap(),
          sectionTitle('Course Terbaru'),
          gap(8),
          const _RecentCourses(),
        ],
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