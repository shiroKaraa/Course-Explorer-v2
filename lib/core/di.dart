import '../repositories/course_repository.dart';
import '../services/course_api_service.dart';
import 'app_config.dart';

class DI {
  DI._();

  static final CourseApiService courseApiService = 
      CourseApiService(AppConfig.apiBaseUrl);

  static final CourseRepository courseRepository =
      CourseRepositoryImpl(courseApiService);
}