import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../providers/course_provider.dart';
import '../widgets/app_card.dart';

class ProviderStatusCard extends StatelessWidget {
  const ProviderStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CourseProvider>();
    return AppCard(
      borderColor: AppColors.primary.withValues(alpha: 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        cardHeader(
          Icons.hub_outlined,
          'Provider Terpasang',
          Text('Tahap 6', style: ts(12, color: Colors.black54)),
          color: AppColors.primary,
        ),
        gap(10),
        _row(Icons.check_circle, 'Status', 'ChangeNotifierProvider aktif',
            color: AppColors.success),
        _row(Icons.inventory_2_outlined, 'Package', 'provider: ^6.1.2'),
        _row(Icons.account_tree_outlined, 'Tipe',
            'ChangeNotifierProvider<CourseProvider>'),
        _row(Icons.place_outlined, 'Lokasi',
            'Membungkus MaterialApp di MyApp'),
        _row(Icons.star_outline, 'Favorite via provider',
            '${provider.favoriteCount}'),
        gap(10),
        hint(
            'Kartu ini memakai context.read<CourseProvider>() untuk mengambil instance. read() tidak memicu rebuild, cocok untuk data status yang tidak perlu di-update terus-menerus.'),
      ]),
    );
  }

  Widget _row(IconData icon, String label, String value,
          {Color color = Colors.black87}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: ts(12, color: Colors.black54)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: ts(12, w: FontWeight.w600, color: color)),
          ),
        ]),
      );
}