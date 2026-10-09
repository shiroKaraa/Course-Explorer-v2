import 'package:flutter/foundation.dart';
import 'models/course.dart';
import 'repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository;

  CourseProvider(this._repository);


  final Set<String> _favorites = <String>{};

  Set<String> get favorites => Set.unmodifiable(_favorites);

  int get favoriteCount => _favorites.length;

  bool isFavorite(String code) => _favorites.contains(code);

  void toggleFavorite(String code) {
    if (_favorites.contains(code)) {
      _favorites.remove(code);
    } else {
      _favorites.add(code);
    }
    notifyListeners();
  }

  void setFavorite(String code, bool value) {
    if (value) {
      _favorites.add(code);
    } else {
      _favorites.remove(code);
    }
    notifyListeners();
  }

  void clearFavorites() {
    if (_favorites.isEmpty) return;
    _favorites.clear();
    notifyListeners();
  }


  List<Course> _courses = const [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;

  List<Course> get courses => List.unmodifiable(_courses);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoaded => _hasLoaded;

  String get asyncStateLabel {
    if (_isLoading) return 'loading';
    if (_error != null) return 'error';
    if (_hasLoaded) return 'success';
    return 'initial';
  }

  Future<void> loadCourses() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getCourses();
      _courses = List<Course>.from(result);
      _hasLoaded = true;
    } catch (e) {
      _error = e.toString();
      _courses = const [];
      _hasLoaded = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _hasLoaded = false;
    _error = null;
    await loadCourses();
  }
}