import '../models/course.dart';
import '../services/course_service.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();


  Future<Map<String, dynamic>> getStudent();
}

class CourseRepositoryImpl implements CourseRepository {
  final CourseService _service;

  CourseRepositoryImpl(this._service);

  @override
  Future<List<Course>> getCourses() => _service.loadCourses();

  @override
  Future<Map<String, dynamic>> getStudent() => _service.loadStudent();
}