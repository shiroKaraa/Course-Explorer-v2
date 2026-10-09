import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../widgets/app_card.dart';

class HomeDashboardPageV3 extends StatefulWidget {
  const HomeDashboardPageV3({super.key});

  @override
  State<HomeDashboardPageV3> createState() => _HomeDashboardPageV3State();
}

class _HomeDashboardPageV3State extends State<HomeDashboardPageV3> {
  int _favoriteCount = 0;

  void _increment() => setState(() => _favoriteCount++);
  void _decrement() {
    if (_favoriteCount == 0) return;
    setState(() => _favoriteCount--);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.warn.withValues(alpha: 0.35),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.arrow_upward,
          'Lifting State Up (setState)',
          Text('Tahap 3', style: ts(12, color: Colors.black54)),
          color: AppColors.warn,
        ),
        gap(10),
        hint(
            'Parent memiliki _favoriteCount. Tiga child menerima lewat constructor; satu child mengirim aksi lewat callback.'),
        gap(12),
        Row(children: [
          Expanded(
            child: CourseSummaryTileV3(favoriteCount: _favoriteCount),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FavoriteTogglePanelV3(
              favoriteCount: _favoriteCount,
              onIncrement: _increment,
              onDecrement: _decrement,
            ),
          ),
        ]),
        gap(10),
        DashboardStatusBarV3(favoriteCount: _favoriteCount),
      ]),
    );
  }
}

class CourseSummaryTileV3 extends StatelessWidget {
  final int favoriteCount;

  const CourseSummaryTileV3({super.key, required this.favoriteCount});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.summarize_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('Ringkasan',
                style: ts(12, w: FontWeight.bold, color: AppColors.primary)),
          ]),
          gap(6),
          Text('Favorite saat ini:', style: ts(11, color: Colors.black54)),
          Text('$favoriteCount',
              style: ts(22, w: FontWeight.bold, color: AppColors.primary)),
          gap(4),
          hint('read-only dari parent'),
        ]),
      );
}

class FavoriteTogglePanelV3 extends StatelessWidget {
  final int favoriteCount;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const FavoriteTogglePanelV3({
    super.key,
    required this.favoriteCount,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.tune, size: 18, color: AppColors.success),
            const SizedBox(width: 6),
            Text('Kontrol',
                style: ts(12, w: FontWeight.bold, color: AppColors.success)),
          ]),
          gap(6),
          hint('Nilai dibaca: $favoriteCount'),
          gap(6),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onDecrement,
                style: outlined(AppColors.muted, pad: 8),
                child: const Icon(Icons.remove, size: 16),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ElevatedButton(
                onPressed: onIncrement,
                style: filled(AppColors.success, pad: 8),
                child: const Icon(Icons.add, size: 16),
              ),
            ),
          ]),
        ]),
      );
}

class DashboardStatusBarV3 extends StatelessWidget {
  final int favoriteCount;

  const DashboardStatusBarV3({super.key, required this.favoriteCount});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Status: $favoriteCount favorite aktif di dashboard',
              style: ts(12, color: Colors.black87),
            ),
          ),
          Text('child ke-3',
              style: ts(10, italic: FontStyle.italic, color: AppColors.muted)),
        ]),
      );
}