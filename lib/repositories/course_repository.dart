import '../models/course.dart';
import '../services/course_api_service.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();
  Future<Course> createCourse(Course course);
  Future<void> updateCourse(int id, Course course);
}

class CourseRepositoryImpl implements CourseRepository {
  final CourseApiService _apiService; 

  CourseRepositoryImpl(this._apiService);

  @override
  Future<List<Course>> getCourses() => _apiService.getCourses(); 

  @override
  Future<Course> createCourse(Course course) => _apiService.createCourse(course);

  @override
  Future<void> updateCourse(int id, Course course) => _apiService.updateCourse(id, course);

}