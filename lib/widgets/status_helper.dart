import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';

class StatusHelper {
  static const _map = {
    'done': (AppColors.success, Icons.check_circle, 'Selesai', 1.0),
    'active': (AppColors.warn, Icons.play_circle, 'Berjalan', 0.5),
  };

  static (Color, IconData, String, double) _of(String s) =>
      _map[s] ?? (AppColors.muted, Icons.schedule, 'Belum', 0.0);

  static Color color(String s) => _of(s).$1;
  static IconData icon(String s) => _of(s).$2;
  static String label(String s) => _of(s).$3;
  static double progressOf(String s) => _of(s).$4;

  static Widget badge(String s) {
    final c = color(s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label(s), style: ts(11, w: FontWeight.bold, color: c)),
    );
  }
}