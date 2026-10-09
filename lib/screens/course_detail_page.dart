import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/demo_scaffold.dart';
import '../widgets/identity_card.dart';
import '../widgets/info_card.dart';
import '../widgets/scroll_page.dart';
import '../widgets/status_helper.dart';

void openCourse(BuildContext context, Course course) {
  go(context, CourseDetailPage(course: course));
}

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool _showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final code = course.code;
    final provider = context.watch<CourseProvider>();
    final isFavorite = provider.isFavorite(code);
    final status = course.status;
    final color = StatusHelper.color(status);
    final progress = course.progress;
    final desc = course.description.isEmpty
        ? 'Tidak ada deskripsi.'
        : course.description;

    return DemoScaffold(
      body: ScrollPage([
        AppCard(
          padding: const EdgeInsets.all(16),
          borderColor: color.withValues(alpha: 0.4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(StatusHelper.icon(status), color: color, size: 28),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(course.title,
                      style: ts(18, w: FontWeight.bold))),
            ]),
            gap(10),
            Row(children: [
              Text(course.summary, style: ts(13, color: Colors.black54)),
              const Spacer(),
              StatusHelper.badge(status),
            ]),
            gap(14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
            ),
            gap(6),
            Row(children: [
              const Icon(Icons.trending_up, size: 14, color: AppColors.success),
              const SizedBox(width: 6),
              Text('Progress: ${(progress * 100).round()}%',
                  style:
                      ts(12, w: FontWeight.w600, color: AppColors.success)),
            ]),
          ]),
        ),
        gap(),
        ...section(
          'Deskripsi',
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _showFullDescription
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Text(desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ts(13, height: 1.5)),
                secondChild: Text(desc, style: ts(13, height: 1.5)),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(
                      () => _showFullDescription = !_showFullDescription),
                  icon: Icon(
                    _showFullDescription
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 18,
                  ),
                  label: Text(_showFullDescription
                      ? 'Sembunyikan'
                      : 'Selengkapnya'),
                ),
              ),
            ]),
          ),
        ),
        ...section(
          'Informasi Course',
          InfoCard([
            InfoRow(Icons.tag, 'Kode', code),
            InfoRow(Icons.credit_card, 'SKS', '${course.credits} SKS'),
            InfoRow(Icons.person, 'Dosen', course.dosen),
            InfoRow(Icons.info_outline, 'Status', course.statusLabel),
          ]),
        ),
        ...section('Identitas Mahasiswa', const IdentityCard()),
        OutlinedButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: code));
            if (!context.mounted) return;
            showMsg(context, 'Kode course "$code" disalin.');
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Salin Kode Course'),
          style: outlined(AppColors.primary),
        ),
        gap(10),
        ElevatedButton.icon(
          onPressed: () {
            context.read<CourseProvider>().toggleFavorite(code);
            final nowFav = context.read<CourseProvider>().isFavorite(code);
            showMsg(
              context,
              '${course.title} '
              '${nowFav ? 'ditandai sebagai favorite!' : 'dihapus dari favorite.'}',
              color: nowFav ? AppColors.success : AppColors.primary,
            );
          },
          icon: Icon(isFavorite ? Icons.star : Icons.star_border, size: 18),
          label: Text(isFavorite
              ? 'Hapus dari Favorite'
              : 'Tandai sebagai Favorite'),
          style: filled(isFavorite ? AppColors.muted : AppColors.success),
        ),
      ]),
    );
  }
}