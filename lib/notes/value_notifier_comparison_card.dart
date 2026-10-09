import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/app_card.dart';

class ValueNotifierComparisonCard extends StatelessWidget {
  const ValueNotifierComparisonCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.primary.withValues(alpha: 0.35),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.compare_arrows,
            'Perbandingan setState vs ValueNotifier',
            Text('Tahap 4', style: ts(12, color: Colors.black54)),
            color: AppColors.primary,
          ),
          gap(10),
          _row('Pemilik state', 'Widget (State class)',
              'ValueNotifier global'),
          _row('Child menerima nilai lewat', 'Constructor',
              'Reference notifier'),
          _row('Child mengubah nilai lewat', 'Callback parent',
              'notifier.value = ...'),
          _row('Rebuild dipicu oleh', 'setState()',
              'notifier.value berubah'),
          _row('Cakupan rebuild', 'Seluruh subtree parent',
              'Hanya ValueListenableBuilder'),
        ]),
      );

  Widget _row(String label, String v3, String v4) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(11, w: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(
              child: Text('setState: $v3',
                  style: ts(11, color: AppColors.warn, height: 1.3)),
            ),
            Expanded(
              child: Text('Notifier: $v4',
                  style: ts(11, color: AppColors.success, height: 1.3)),
            ),
          ]),
        ]),
      );
}