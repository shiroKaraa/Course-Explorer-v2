import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/app_card.dart';

class ChangeNotifierComparisonCard extends StatelessWidget {
  const ChangeNotifierComparisonCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.success.withValues(alpha: 0.35),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.sync_alt,
            'Perbandingan ValueNotifier vs ChangeNotifier',
            Text('Tahap 5', style: ts(12, color: Colors.black54)),
          ),
          gap(10),
          _row('Menyimpan', 'Satu nilai', 'Banyak field sekaligus'),
          _row('Method sendiri', 'Tidak bisa', 'Bisa (toggleFavorite)'),
          _row('Notifikasi', 'notifier.value = ...', 'notifyListeners()'),
          _row('Logika terkait', 'Di luar class', 'Di dalam class'),
          _row('Cocok untuk', 'Satu nilai sederhana',
              'State gabungan + logika'),
        ]),
      );

  Widget _row(String label, String v4, String v5) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(11, w: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(
              child: Text('ValueNotifier: $v4',
                  style: ts(11, color: AppColors.primary, height: 1.3)),
            ),
            Expanded(
              child: Text('ChangeNotifier: $v5',
                  style: ts(11, color: AppColors.success, height: 1.3)),
            ),
          ]),
        ]),
      );
}