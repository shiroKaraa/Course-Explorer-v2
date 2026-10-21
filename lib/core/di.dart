import '../repositories/course_repository.dart';  
import '../services/course_supabase_service.dart';  
import '../services/course_data_source.dart';

class DI {
  DI._();


  static final CourseDataSource dataSource = 
      CourseSupabaseService();

  static final CourseRepository courseRepository = 
      CourseRepository(dataSource);
}