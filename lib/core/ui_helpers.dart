import 'package:flutter/material.dart';
import 'app_colors.dart';

TextStyle ts(
  double size, {
  Color color = Colors.black87,
  FontWeight? w,
  FontStyle? italic,
  double? height,
}) =>
    TextStyle(
      fontSize: size,
      color: color,
      fontWeight: w,
      fontStyle: italic,
      height: height,
    );

Widget gap([double h = 16]) => SizedBox(height: h);

Widget hint(String t) => Text(t, style: ts(12, color: Colors.black54));

Widget sectionTitle(String t) =>
    Text(t, style: ts(16, w: FontWeight.bold, color: Colors.black));

List<Widget> section(String title, Widget child) =>
    [sectionTitle(title), gap(8), child, gap()];

Widget cardHeader(
  IconData icon,
  String title,
  Widget trailing, {
  Color color = AppColors.success,
  double iconSize = 20,
}) =>
    Row(children: [
      Icon(icon, color: color, size: iconSize),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          style: ts(15, w: FontWeight.bold, color: color),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      const Spacer(),
      trailing,
    ]);

final _btnShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

ButtonStyle filled(Color bg, {double pad = 14}) => ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: pad),
      shape: _btnShape,
    );

ButtonStyle outlined(Color c, {double pad = 14}) => OutlinedButton.styleFrom(
      foregroundColor: c,
      side: BorderSide(color: c),
      padding: EdgeInsets.symmetric(vertical: pad),
      shape: _btnShape,
    );

int columnsFor(double width) => width < 600 ? 1 : (width < 840 ? 2 : 3);