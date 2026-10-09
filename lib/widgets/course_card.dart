import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import 'app_card.dart';
import 'status_helper.dart';

class CourseCard extends StatefulWidget {
  final Json course;
  final bool isFavorite;
  final VoidCallback? onTap, onLongPress;
  final VoidCallback? onToggleFavorite;

  const CourseCard({
    super.key,
    required this.course,
    this.isFavorite = false,
    this.onTap,
    this.onLongPress,
    this.onToggleFavorite,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _showDescription = false;

  void _toggleDescription() =>
      setState(() => _showDescription = !_showDescription);

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final status = course.status;
    final color = StatusHelper.color(status);
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      borderColor: widget.isFavorite
          ? AppColors.success.withValues(alpha: 0.6)
          : color.withValues(alpha: 0.25),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(StatusHelper.icon(status), color: color, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(course.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ts(14, w: FontWeight.bold, color: Colors.black)),
          ),
          if (widget.onToggleFavorite != null)
            InkWell(
              onTap: widget.onToggleFavorite,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  widget.isFavorite ? Icons.star : Icons.star_border,
                  color: widget.isFavorite
                      ? AppColors.success
                      : AppColors.muted,
                  size: 20,
                ),
              ),
            )
          else if (widget.isFavorite)
            const Icon(Icons.star, color: AppColors.success, size: 18),
        ]),
        gap(4),
        Text('${course.str('code')} • ${course.str('credits')} SKS',
            style: ts(11, color: Colors.black54)),
        gap(4),
        Expanded(
          child: _showDescription
              ? SingleChildScrollView(
                  child: Text(course.str('description', ''),
                      style: ts(11, color: Colors.black87, height: 1.4)),
                )
              : Text(course.str('description', ''),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: ts(11, color: Colors.black45, height: 1.3)),
        ),
        Row(children: [
          Expanded(
            child: Text('Dosen: ${course.str('dosen')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    ts(10, color: Colors.black45, italic: FontStyle.italic)),
          ),
          InkWell(
            onTap: _toggleDescription,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(children: [
                Text(_showDescription ? 'Tutup' : 'Detail',
                    style: ts(10,
                        w: FontWeight.bold, color: AppColors.primary)),
                Icon(
                  _showDescription
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 14,
                  color: AppColors.primary,
                ),
              ]),
            ),
          ),
          const SizedBox(width: 4),
          StatusHelper.badge(status),
        ]),
      ]),
    );
  }
}