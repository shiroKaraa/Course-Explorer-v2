import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/ui_helpers.dart';

class GalleryHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const GalleryHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: ts(18, w: FontWeight.bold, color: Colors.black)),
            ),
          ]),
          gap(10),
          Text(subtitle,
              style: ts(12, color: Colors.black54, height: 1.5)),
        ]),
      );
}

class GallerySectionDivider extends StatelessWidget {
  final String tahap;
  final String title;
  final String description;
  final Color color;

  const GallerySectionDivider({
    super.key,
    required this.tahap,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(tahap,
                  style: ts(10, w: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: ts(14, w: FontWeight.bold, color: Colors.black)),
            ),
          ]),
          gap(6),
          Text(description,
              style: ts(11, color: Colors.black54, height: 1.4)),
        ]),
      );
}

class GalleryFooter extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const GalleryFooter({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: ts(14, w: FontWeight.bold, color: Colors.black)),
                gap(4),
                Text(description,
                    style: ts(11, color: Colors.black54, height: 1.4)),
              ],
            ),
          ),
        ]),
      );
}