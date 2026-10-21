import '../repositories/course_repository.dart';
import '../services/course_api_service.dart';
import '../services/course_data_source.dart';
import 'app_config.dart';

class DI {
  DI._();


  static final CourseDataSource dataSource = 
      CourseApiService(AppConfig.apiBaseUrl);

  static final CourseRepository courseRepository = 
      CourseRepository(dataSource);
}