import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../screens/course_detail_page.dart';
import 'app_card.dart';

class FavoriteSectionCard extends StatelessWidget {
  const FavoriteSectionCard({super.key});

  @override
  Widget build(BuildContext context) => Consumer<CourseProvider>(
        builder: (context, provider, _) {
          if (!provider.hasLoaded) {
            return AppCard(
              borderColor: AppColors.gold.withValues(alpha: 0.35),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          final favCourses = provider.courses
              .where((c) => provider.isFavorite(c.code))
              .toList();
          return AppCard(
            borderColor: AppColors.gold.withValues(alpha: 0.4),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              cardHeader(
                Icons.star,
                'Course Favorite',
                Text('${favCourses.length}',
                    style: ts(13, w: FontWeight.bold, color: AppColors.gold)),
                color: AppColors.gold,
              ),
              gap(10),
              if (favCourses.isEmpty)
                hint('Belum ada course favorite. Tap ikon ⭐ di kartu course atau di halaman detail.')
              else
                for (final c in favCourses) _favItem(context, c),
            ]),
          );
        },
      );

  Widget _favItem(BuildContext context, Course c) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => openCourse(context, c),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(children: [
              const Icon(Icons.bookmark, size: 16, color: AppColors.gold),
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