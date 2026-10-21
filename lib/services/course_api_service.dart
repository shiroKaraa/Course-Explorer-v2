import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';

class CourseApiService {
  final String baseUrl;

  CourseApiService(this.baseUrl);

  Future<List<Course>> getCourses() async { 
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => Course.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('HTTP ${response.statusCode}: Gagal mengambil data');
    }
  }
}