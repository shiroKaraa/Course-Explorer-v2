import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/app_card.dart';

class LiftingStateUpNoteCard extends StatelessWidget {
  const LiftingStateUpNoteCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.success.withValues(alpha: 0.35),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.arrow_upward,
            'Catatan Lifting State Up',
            Text('Tahap 3', style: ts(12, color: Colors.black54)),
          ),
          gap(10),
          _bullet('State _favoriteCount diangkat ke ancestor terdekat.'),
          _bullet('HomeDashboardPage menjadi Single Source of Truth.'),
          _bullet('Tiga child menerima nilai yang sama lewat constructor.'),
          _bullet('Hanya FavoriteTogglePanel yang menerima callback.'),
        ]),
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.circle, size: 6, color: AppColors.success),
          ),
          Expanded(
            child: Text(text,
                style: ts(12, color: Colors.black87, height: 1.4)),
          ),
        ]),
      );
}