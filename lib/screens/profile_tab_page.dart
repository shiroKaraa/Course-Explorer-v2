import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';           
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../widgets/app_card.dart';
import '../widgets/identity_card.dart';
import '../widgets/info_card.dart';
import '../widgets/scroll_page.dart';
import '../notes/state_classification_card.dart';
import '../notes/prop_drilling_note_card.dart';
import '../notes/lifting_state_up_note_card.dart';
import '../notes/value_notifier_comparison_card.dart';
import '../notes/change_notifier_comparison_card.dart';
import '../notes/provider_status_card.dart';
import '../notes/provider_patterns_comparison_card.dart';
import '../demos/tahap_8_demo.dart';
import '../demos/tahap_9_demo.dart';
import '../demos/tahap_10_demo.dart';
import '../demos/tahap_11_demo.dart';
import '../demos/tahap_5_6_7_demo.dart';        

class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) => ScrollPage([
        const IdentityCard(
            subtitle: 'Pendidikan Teknik Informatika • Semester 5'),
        gap(),
        ListenableBuilder(
          listenable: Listenable.merge([favorites, quizScore]),
          builder: (_, __) => Row(children: [
            const _StatTile(Icons.book_outlined, 'Topik', '5'),
            const SizedBox(width: 10),
            _StatTile(Icons.star_outline, 'Favorite',
                '${favorites.value.length}',
                color: AppColors.success),
            const SizedBox(width: 10),
            _StatTile(Icons.emoji_events_outlined, 'Quiz',
                quizScore.value?.toString() ?? '-',
                color: AppColors.warn),
          ]),
        ),
        gap(),
        const StateClassificationCard(),
        gap(),
        const AsyncStateIndicatorCard(),
        gap(),
        const ProviderStatusCard(),
        gap(),
        const ProviderPatternsComparisonCard(),
        gap(),
        const AsyncStateComparisonCard(),
        gap(),
        const CourseRepositoryComparisonCard(),
        gap(),
        const CourseServiceComparisonCard(),
        gap(),
        const CourseModelComparisonCard(),
        gap(),
        const PropDrillingNoteCard(),
        gap(),
        const LiftingStateUpNoteCard(),
        gap(),
        const ValueNotifierComparisonCard(),
        gap(),
        const ChangeNotifierComparisonCard(),
        gap(),
        ...section(
          'Informasi Mahasiswa',
          const InfoCard([
            InfoRow(Icons.person_outline, 'Nama', studentName),
            InfoRow(Icons.badge_outlined, 'NIM', studentId),
            InfoRow(Icons.school_outlined, 'Program Studi',
                'Pendidikan Teknik Informatika'),
            InfoRow(Icons.calendar_today_outlined, 'Semester', '5'),
          ], padding: EdgeInsets.all(16)),
        ),
        ...section(
          'About Me',
          AppCard(child: hint('Mahasiswa Pendidikan Teknik Informatika')),
        ),
        ...section(
          'About Application',
          AppCard(
            borderColor: AppColors.primary.withValues(alpha: 0.3),
            child: hint('Course Explorer v2'),
          ),
        ),
        ...section('Daftar Favorite', const FavoriteSectionCard()),
      ]);
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