import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';

class CourseApiService {
  final String baseUrl;

  CourseApiService(this.baseUrl);

  Future<List<dynamic>> fetchCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('HTTP ${response.statusCode}: Gagal mengambil data');
    }
  }
}