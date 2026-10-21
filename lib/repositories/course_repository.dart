import '../models/course.dart';
import '../services/course_api_service.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();
}

class CourseRepositoryImpl implements CourseRepository {
  final CourseApiService _apiService; 

  CourseRepositoryImpl(this._apiService);

  @override
  Future<List<Course>> getCourses() => _apiService.getCourses(); 
}