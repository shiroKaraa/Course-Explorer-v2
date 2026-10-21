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
  Future<Course> createCourse(Course course) async {
    final insertData = {
      'code': course.code,
      'title': course.title,
      'credits': course.credits,
      'status': course.status,
      'description': course.description,
      'dosen': course.dosen,
    };

    try {
      final data = await _supabase
          .from('courses')
          .insert(insertData)
          .select()
          .single();

      return Course.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == '23505') { 
        throw Exception('Kode course "${course.code}" sudah digunakan.');
      }
      throw Exception('Database error: ${e.message}');
    }
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    final updateData = {
      'title': course.title,
      'credits': course.credits,
      'status': course.status,
      'description': course.description,
      'dosen': course.dosen,
    };

    try {
      await _supabase
          .from('courses')
          .update(updateData)
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    try {
      await _supabase
          .from('courses')
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    }
  }

}