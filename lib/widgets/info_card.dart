import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import 'app_card.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;

  const InfoRow(this.icon, this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(label, style: ts(13, color: Colors.black54)),
        const Spacer(),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: ts(13, w: FontWeight.w600)),
        ),
      ]);
}

class InfoCard extends StatelessWidget {
  final List<InfoRow> rows;
  final EdgeInsets padding;

  const InfoCard(this.rows, {super.key, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) => AppCard(
        padding: padding,
        child: Column(children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 20),
            rows[i],
          ],
        ]),
      );
}