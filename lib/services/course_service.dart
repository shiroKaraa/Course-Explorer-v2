import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/course.dart';

class CourseService {
  static const String assetPath = 'assets/data/student_data.json';


  Future<List<Course>> loadCourses() async {
    final rawString = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(rawString) as Map<String, dynamic>;
    final rawList = (decoded['courses'] as List?) ?? const [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(Course.fromJson)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> loadStudent() async {
    final rawString = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(rawString) as Map<String, dynamic>;
    return (decoded['student'] as Map?)?.cast<String, dynamic>() ?? {};
  }
}