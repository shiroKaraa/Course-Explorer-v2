import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/app_card.dart';

class AsyncStateComparisonCard extends StatelessWidget {
  const AsyncStateComparisonCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.primary.withValues(alpha: 0.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.sync_problem_outlined,
            'FutureBuilder vs Provider Async State',
            Text('Tahap 11', style: ts(12, color: Colors.black54)),
            color: AppColors.primary,
          ),
          gap(10),
          _row('Pengelola state', 'FutureBuilder (di widget)',
              'CourseProvider (di luar widget)'),
          _row('Kapan load dipanggil', 'Setiap build bisa trigger',
              'Sekali di initState / refresh()'),
          _row('Loading', 'connectionState.waiting', 'isLoading == true'),
          _row('Error', 'snapshot.hasError', 'error != null'),
          _row('Success', 'snapshot.data', 'courses.isNotEmpty / hasLoaded'),
          _row('Retry', 'Bikin Future baru', 'provider.refresh()'),
          _row('Dipakai lintas screen', 'Sulit (perlu widget sendiri)',
              'Ya (watch provider)'),
          gap(6),
          hint(
              'Kesimpulan: provider memusatkan async state sehingga loading/error/success dikelola sekali, bisa di-retry, dan bisa diakses lintas screen.'),
        ]),
      );

  Widget _row(String label, String before, String after) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(11, w: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(
              child: Text('FutureBuilder: $before',
                  style: ts(11, color: AppColors.warn, height: 1.3)),
            ),
            Expanded(
              child: Text('Provider: $after',
                  style: ts(11, color: AppColors.success, height: 1.3)),
            ),
          ]),
        ]),
      );
}