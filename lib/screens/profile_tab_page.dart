import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/app_strings.dart';
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../providers/course_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/identity_card.dart';
import '../widgets/info_card.dart';
import '../widgets/scroll_page.dart';
import '../demos/tahap_5_6_7_demo.dart';
import 'notes_gallery_page.dart';
import 'about_page.dart';

class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    return ScrollPage([

      const IdentityCard(
          subtitle: 'Pendidikan Teknik Informatika • Semester 5'),
      gap(),
      Row(children: [
        const _StatTile(Icons.book_outlined, 'Topik', '5'),
        const SizedBox(width: 10),
        _StatTile(Icons.star_outline, 'Favorite', '${provider.favoriteCount}',
            color: AppColors.gold),
        const SizedBox(width: 10),
        _StatTile(Icons.emoji_events_outlined, 'Quiz',
            quizScore.value?.toString() ?? '-',
            color: AppColors.warn),
      ]),
      gap(),
      ...section(
        'Informasi Mahasiswa',
        const InfoCard([
          InfoRow(Icons.person_outline, 'Nama', studentName),
          InfoRow(Icons.badge_outlined, 'NIM', studentId),
          InfoRow(Icons.school_outlined, 'Program Studi',
              'Pendidikan Teknik Informatika'),
          InfoRow(Icons.calendar_today_outlined, 'Kelas', 'PTI 5A'),
          InfoRow(Icons.calendar_today_outlined, 'Semester', '5'),
        ], padding: EdgeInsets.all(16)),
      ),
      ...section(
        'About Me',
        AppCard(child: hint('Mahasiswa Pendidikan Teknik Informatika')),
      ),
      const _NotesButton(),
      gap(10),
      const _AboutButton(),
      gap(),
      ...section('Daftar Favorite', const FavoriteSectionCard()),
    ]);
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _StatTile(this.icon, this.label, this.value,
      {this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: ts(18, w: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: ts(12, color: Colors.black54)),
          ]),
        ),
      );
}


class _NotesButton extends StatelessWidget {
  const _NotesButton();

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => go(context, const NotesGalleryPage()),
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
            border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book_outlined,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lihat Catatan Tahapan',
                      style:
                          ts(14, w: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 2),
                  Text(
                    'Perbandingan konsep dari setiap tahap',
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

class _AboutButton extends StatelessWidget {
  const _AboutButton();

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => go(context, const AboutPage()),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.info_outline,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tentang Aplikasi',
                      style:
                          ts(14, w: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 2),
                  Text(
                    'Info aplikasi, teknologi, dan arsitektur',
                    style: ts(11, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.primary, size: 24),
          ]),
        ),
      );
}