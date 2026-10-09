import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_strings.dart';
import '../core/ui_helpers.dart';
import '../widgets/app_card.dart';
import '../widgets/demo_scaffold.dart';
import '../widgets/info_card.dart';
import '../widgets/scroll_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => DemoScaffold(
        body: ScrollPage([
          // ===== LOGO & TITLE =====
          const _HeaderCard(),
          gap(),

          // ===== TENTANG APLIKASI =====
          ...section(
            'Tentang Aplikasi',
            AppCard(
              borderColor: AppColors.primary.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Course Explorer v2',
                      style: ts(16, w: FontWeight.bold, color: Colors.black)),
                  gap(6),
                  Text(
                    'Aplikasi eksplorasi course yang dibangun sebagai mini project Praktikum Pemrograman Mobile Pertemuan 6. '
                    'Menerapkan state management dengan Provider, architecture bertingkat (Model → Service → Repository → Provider → UI), '
                    'serta shared favorites state yang konsisten lintas screen.',
                    style: ts(12, color: Colors.black54, height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          // ===== INFORMASI MAHASISWA =====
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

          // ===== TEKNOLOGI =====
          ...section(
            'Teknologi',
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _techRow('Flutter', 'Framework UI cross-platform'),
                  _techRow('Dart', 'Bahasa pemrograman'),
                  _techRow('Provider', 'State management'),
                  _techRow('ChangeNotifier', 'State holder'),
                ],
              ),
            ),
          ),

          // ===== ARSITEKTUR =====
          ...section(
            'Arsitektur',
            AppCard(
              borderColor: AppColors.success.withValues(alpha: 0.35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alur Data',
                      style: ts(13, w: FontWeight.bold, color: Colors.black)),
                  gap(8),
                  _archStep('UI (Screens & Widgets)', 1),
                  _archStep('Provider (CourseProvider)', 2),
                  _archStep('Repository (CourseRepository)', 3),
                  _archStep('Service (CourseService)', 4),
                  _archStep('Data Source (JSON Asset)', 5),
                ],
              ),
            ),
          ),
          gap(),

          // ===== FOOTER =====
          Center(
            child: Text(
              '© 2026 — Praktikum Pemrograman Mobile',
              style: ts(11, color: Colors.black45, italic: FontStyle.italic),
            ),
          ),
        ]),
      );

  Widget _techRow(String name, String desc) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(name,
                style: ts(11, w: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(desc, style: ts(11, color: Colors.black54)),
          ),
        ]),
      );

  Widget _archStep(String text, int step) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text('$step',
                style: ts(11, w: FontWeight.bold, color: AppColors.success)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: ts(12, color: Colors.black87, height: 1.4)),
          ),
        ]),
      );
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.15),
              AppColors.primarySoft,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          // Logo Undiksha
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/images/logo_undiksha.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.school,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          gap(14),
          Text(appTitle,
              style: ts(20, w: FontWeight.bold, color: Colors.black)),
          gap(4),
          Text('Mini Project Praktikum Pemrograman Mobile',
              style: ts(12, color: Colors.black54)),
          gap(2),
          Text('Pertemuan 6 — State Management & Architecture',
              style: ts(11, color: Colors.black45, italic: FontStyle.italic)),
        ]),
      );
}