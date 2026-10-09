import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../repositories/course_repository.dart';
import '../services/course_service.dart';
import 'app_colors.dart';
import 'di.dart';
import 'ui_helpers.dart';

typedef Json = Map<String, dynamic>;
final Future<Json> studentDataFuture = rootBundle
    .loadString('assets/data/student_data.json')
    .then((s) => jsonDecode(s) as Json);

final quizScore = ValueNotifier<int?>(null);
final courseFilter = ValueNotifier<String>('all');
final favoriteCounter = ValueNotifier<int>(0);

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