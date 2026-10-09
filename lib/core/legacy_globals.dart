import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../repositories/course_repository.dart';
import '../services/course_service.dart';
import '../screens/course_detail_page.dart';
import 'app_colors.dart';
import 'app_strings.dart';
import 'di.dart';
import 'ui_helpers.dart';

typedef Json = Map<String, dynamic>;

final Future<Json> studentDataFuture = rootBundle
    .loadString('assets/data/student_data.json')
    .then((s) => jsonDecode(s) as Json);

final favorites = ValueNotifier<Set<String>>(<String>{});
final quizScore = ValueNotifier<int?>(null);
final courseFilter = ValueNotifier<String>('all');
final favoriteCounter = ValueNotifier<int>(0);

// Service & repository sekarang diambil dari DI, bukan dibuat ulang.
final CourseService courseService = DI.courseService;
final CourseRepository courseRepository = DI.courseRepository;

extension CourseX on Json {
  String str(String k, [String d = '-']) => this[k]?.toString() ?? d;
  String get code => str('code', '');
  String get title => str('title', 'Tanpa Judul');
  String get status => str('status', 'planned');
}

void go(BuildContext c, Widget page) =>
    Navigator.push(c, MaterialPageRoute(builder: (_) => page));

void showMsg(BuildContext c, String msg,
    {Color color = AppColors.primary, SnackBarAction? action}) {
  ScaffoldMessenger.of(c)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      action: action,
    ));
}

void setFavorite(String code, bool value) => favorites.value = value
    ? {...favorites.value, code}
    : ({...favorites.value}..remove(code));

Widget withCourses(
  Widget Function(Json data, List<Json> courses) build, {
  bool handleStates = true,
}) {
  return FutureBuilder<Json>(
    future: studentDataFuture,
    builder: (context, snap) {
      if (handleStates) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || snap.data == null) {
          return Center(
            child: Text('Gagal memuat data: ${snap.error}',
                style: const TextStyle(color: Colors.red)),
          );
        }
      }
      final data = snap.data ?? {};
      return build(data, ((data['courses'] as List?) ?? []).cast<Json>());
    },
  );
}

Future<void> openCourse(BuildContext context, Json course) async {
  final code = course.code;
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => CourseDetailPage(
        course: course,
        isFavorite: favorites.value.contains(code),
      ),
    ),
  );
  if (result == null || !context.mounted) return;
  setFavorite(code, result);
  showMsg(
    context,
    '${course.str('title', 'Course')} '
    '${result ? 'ditandai sebagai favorite!' : 'dihapus dari favorite.'}',
    color: result ? AppColors.success : AppColors.primary,
  );
}

Future<void> confirmRemoveFavorite(BuildContext context, Json course) async {
  final code = course.code;
  if (!favorites.value.contains(code)) return;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Hapus Favorite?'),
      content:
          Text('Hapus "${course.str('title', 'Course')}" dari daftar favorite?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  setFavorite(code, false);
  showMsg(context, 'Dihapus dari favorite.', color: Colors.red);
}