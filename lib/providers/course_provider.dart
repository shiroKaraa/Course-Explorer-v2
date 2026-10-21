import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository;

  CourseProvider(this._repository);

  // ===== FAVORITES =====
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

  void clearFavorites() {
    if (_favorites.isEmpty) return;
    _favorites.clear();
    notifyListeners();
  }

  // ===== ASYNC COURSES =====
  List<Course> _courses = const [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;
  Future<void>? _inFlightLoad;

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

  Future<void> loadCourses() {
    if (_inFlightLoad != null) return _inFlightLoad!;

    _inFlightLoad = _doLoad();
    return _inFlightLoad!.whenComplete(() => _inFlightLoad = null);
  }

  Future<void> _doLoad() async {
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

  // ===== CREATE =====
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Future<bool> addCourse(Course course) async {
    if (_isSaving) return false;
    _isSaving = true;
    notifyListeners();

    try {
      final created = await _repository.createCourse(course);

      _courses = [created, ..._courses];
      _hasLoaded = true;
      _error = null;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===== UPDATE =====
  Future<bool> editCourse(Course updatedCourse) async {
    if (_isSaving) return false;
    if (updatedCourse.id == null) {
      _error = 'ID Course tidak ditemukan untuk update.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateCourse(updatedCourse.id!, updatedCourse);

      final index =
          _courses.indexWhere((c) => c.id == updatedCourse.id);
      if (index != -1) {
        final newList = List<Course>.from(_courses);
        newList[index] = updatedCourse;
        _courses = newList;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }


  Course? findCourse({int? id, String? code}) {
    for (final c in _courses) {
      if (id != null && c.id == id) return c;
      if (code != null && c.code == code) return c;
    }
    return null;
  }
}