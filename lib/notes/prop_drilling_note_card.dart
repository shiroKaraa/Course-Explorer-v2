import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/app_card.dart';

class PropDrillingNoteCard extends StatelessWidget {
  const PropDrillingNoteCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.warn.withValues(alpha: 0.35),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.warning_amber_outlined,
            'Catatan Prop Drilling',
            Text('Tahap 2', style: ts(12, color: Colors.black54)),
            color: AppColors.warn,
          ),
          gap(10),
          _bullet('State _favoriteCount dimiliki HomeDashboardPage dan harus dikirim ke setiap child lewat constructor.'),
          _bullet('Setiap child yang ingin mengubah nilai harus menerima callback dari parent.'),
          _bullet('Menambah child baru berarti menambah constructor baru — inilah prop drilling.'),
          _bullet('Risiko duplikasi: child yang menyimpan salinan bisa tidak sinkron.'),
        ]),
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.circle, size: 6, color: AppColors.warn),
          ),
          Expanded(
            child: Text(text,
                style: ts(12, color: Colors.black87, height: 1.4)),
          ),
        ]),
      );
}