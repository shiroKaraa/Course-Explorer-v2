import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/app_card.dart';

class CourseRepositoryComparisonCard extends StatelessWidget {
  const CourseRepositoryComparisonCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.success.withValues(alpha: 0.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.storage_outlined,
            'CourseService vs CourseRepository',
            Text('Tahap 10', style: ts(12, color: Colors.black54)),
          ),
          gap(10),
          _row('Peran', 'Detail teknis data', 'Kontrak sumber data'),
          _row('Tahu asset/JSON?', 'Ya', 'Tidak'),
          _row('Bisa diganti?', 'Hanya isinya', 'Ya, via interface'),
          _row('Bisa di-mock?', 'Sulit', 'Ya (FakeCourseRepository)'),
          _row('Dipakai oleh', 'Repository', 'Provider / UI'),
          _row('Contoh perubahan', 'Ganti path JSON', 'Ganti service apa pun'),
          gap(6),
          hint(
              'Kesimpulan: service tahu cara membaca data; repository menyediakan kontrak agar layer atas tidak bergantung pada implementasi konkret.'),
        ]),
      );

  Widget _row(String label, String serviceSide, String repoSide) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(11, w: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(
              child: Text('Service: $serviceSide',
                  style: ts(11, color: AppColors.muted, height: 1.3)),
            ),
            Expanded(
              child: Text('Repo: $repoSide',
                  style: ts(11, color: AppColors.success, height: 1.3)),
            ),
          ]),
        ]),
      );
}