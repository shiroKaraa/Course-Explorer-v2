import 'package:flutter/foundation.dart';

class CourseProvider extends ChangeNotifier {

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
}