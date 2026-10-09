import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../widgets/app_card.dart';

class HomeDashboardPageV4 extends StatelessWidget {
  const HomeDashboardPageV4({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.primary.withValues(alpha: 0.35),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.notifications_active_outlined,
          'ValueNotifier',
          Text('Tahap 4', style: ts(12, color: Colors.black54)),
          color: AppColors.primary,
        ),
        gap(10),
        hint(
            'Nilai disimpan di ValueNotifier<int> global. Tiga child mendengarkan langsung lewat ValueListenableBuilder tanpa constructor nilai.'),
        gap(12),
        Row(children: [
          Expanded(child: CourseSummaryTileV4(counter: favoriteCounter)),
          const SizedBox(width: 10),
          Expanded(child: FavoriteTogglePanelV4(counter: favoriteCounter)),
        ]),
        gap(10),
        DashboardStatusBarV4(counter: favoriteCounter),
      ]),
    );
  }
}

class CourseSummaryTileV4 extends StatelessWidget {
  final ValueNotifier<int> counter;

  const CourseSummaryTileV4({super.key, required this.counter});

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
          ValueListenableBuilder<int>(
            valueListenable: counter,
            builder: (_, value, __) => Text('$value',
                style: ts(22, w: FontWeight.bold, color: AppColors.primary)),
          ),
          gap(4),
          hint('listen langsung'),
        ]),
      );
}

class FavoriteTogglePanelV4 extends StatelessWidget {
  final ValueNotifier<int> counter;

  const FavoriteTogglePanelV4({super.key, required this.counter});

  void _increment() => counter.value = counter.value + 1;
  void _decrement() {
    if (counter.value == 0) return;
    counter.value = counter.value - 1;
  }

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
          ValueListenableBuilder<int>(
            valueListenable: counter,
            builder: (_, value, __) => hint('Nilai dibaca: $value'),
          ),
          gap(6),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _decrement,
                style: outlined(AppColors.muted, pad: 8),
                child: const Icon(Icons.remove, size: 16),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ElevatedButton(
                onPressed: _increment,
                style: filled(AppColors.success, pad: 8),
                child: const Icon(Icons.add, size: 16),
              ),
            ),
          ]),
        ]),
      );
}

class DashboardStatusBarV4 extends StatelessWidget {
  final ValueNotifier<int> counter;

  const DashboardStatusBarV4({super.key, required this.counter});

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
            child: ValueListenableBuilder<int>(
              valueListenable: counter,
              builder: (_, value, __) => Text(
                'Status: $value favorite aktif di dashboard',
                style: ts(12, color: Colors.black87),
              ),
            ),
          ),
          Text('child ke-3',
              style: ts(10, italic: FontStyle.italic, color: AppColors.muted)),
        ]),
      );
}