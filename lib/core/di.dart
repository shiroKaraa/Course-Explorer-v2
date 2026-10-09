import '../repositories/course_repository.dart';
import '../services/course_service.dart';

/// Dependency Injection 
/// Tujuan file ini:
/// - Memusatkan pembuatan instance (service, repository) di satu tempat.
/// - Menghindari pembuatan instance berulang di banyak file.
/// - Menyiapkan jalur menuju DI yang lebih rapi di tahap berikutnya.
///
/// Catatan: ini BUKAN DI framework seperti get_it atau riverpod.
/// Ini hanya "wadah" agar dependency terlihat jelas dari satu titik.
class DI {
  DI._(); // constructor private, tidak untuk diinstansiasi

  // Instance service yang menangani detail teknis data access.
  static final CourseService courseService = CourseService();

  // Instance repository yang membungkus service.
  // Provider akan menerima instance ini lewat constructor.
  static final CourseRepository courseRepository =
      CourseRepositoryImpl(courseService);
}