import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    final data = await _supabase
        .from('courses')
        .select()
        .order('id', ascending: true);

    return (data as List)
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  
  @override
  Future<Course> createCourse(Course course) {
    throw UnimplementedError('Akan diimplementasikan di Tahap 13');
  }

  @override
  Future<void> updateCourse(int id, Course course) {
    throw UnimplementedError('Akan diimplementasikan di Tahap 14');
  }

  @override
  Future<void> deleteCourse(int id) {
    throw UnimplementedError('Akan diimplementasikan di Tahap 15');
  }
}