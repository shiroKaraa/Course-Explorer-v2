import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';

class CourseApiService {
  final String baseUrl;

  CourseApiService(this.baseUrl);

  final List<Course> _createdCourses = [];

  Future<List<Course>> getCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: Gagal mengambil data');
    }

    final List data = jsonDecode(response.body) as List;
    final remote = data
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    return [..._createdCourses.reversed, ...remote];
  }

  Future<Course> createCourse(Course course) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'title': course.title,
        'body': course.description,
        'userId': 1,
        'code': course.code,
        'credits': course.credits,
        'status': course.status,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('HTTP ${response.statusCode}: Gagal membuat course');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    final created = Course(
      id: data['id'] as int?,
      code: course.code,
      title: course.title,
      credits: course.credits,
      status: course.status,
      description: course.description,
      dosen: course.dosen,
    );

    _createdCourses.add(created);
    return created;
  }

  Future<void> updateCourse(int id, Course course) async {
    final isLocalOnly = id > 100;

    if (!isLocalOnly) {
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/posts/$id'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'id': id,
            'title': course.title,
            'body': course.description,
            'userId': 1,
            'code': course.code,
            'credits': course.credits,
            'status': course.status,
          }),
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          print(
            'PUT /posts/$id → HTTP ${response.statusCode} '
            '(diabaikan, update lokal tetap dilakukan)',
          );
        }
      } catch (e) {
        print('PUT /posts/$id gagal: $e (diabaikan)');
      }
    }

    final index = _createdCourses.indexWhere((c) => c.id == id);
    if (index != -1) {
      _createdCourses[index] = course;
    }
  }

}