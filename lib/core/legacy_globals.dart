import 'package:flutter/material.dart';

import '../repositories/course_repository.dart';
import '../services/course_service.dart';
import 'app_colors.dart';
import 'di.dart';

final quizScore = ValueNotifier<int?>(null);
final courseFilter = ValueNotifier<String>('all');

final CourseService courseService = DI.courseService;
final CourseRepository courseRepository = DI.courseRepository;

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