import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';

class CourseApiService {
  final String baseUrl;

  CourseApiService(this.baseUrl);

  /// Cache lokal untuk course yang dibuat lewat POST.
  /// JSONPlaceholder TIDAK menyimpan data baru, jadi kita simpan
  /// sendiri agar tetap muncul setelah refresh().
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

    // Gabungkan: course yang baru dibuat (cache lokal) + data dari server.
    // Course lokal diletakkan di depan agar mudah terlihat.
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
        // Kirim juga code & credits untuk dokumentasi (diabaikan server)
        'code': course.code,
        'credits': course.credits,
        'status': course.status,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('HTTP ${response.statusCode}: Gagal membuat course');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    // Bangun Course final: pertahankan field dari FORM (code, credits, status),
    // hanya ambil id dari server.
    final created = Course(
      id: data['id'] as int?,
      code: course.code,           // ← dari form, bukan generate
      title: course.title,          // ← dari form
      credits: course.credits,      // ← dari form
      status: course.status,        // ← dari form
      description: course.description,
      dosen: course.dosen,
    );

    // Simpan di cache agar muncul di GET berikutnya.
    _createdCourses.add(created);

    return created;
  }
}