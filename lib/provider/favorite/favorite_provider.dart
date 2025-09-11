import 'package:flutter/material.dart';
import '../../data/model/restaurant.dart';
import '../../data/db/favorite_db.dart';

sealed class FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<Restaurant> favorites;
  FavoriteLoaded(this.favorites);
}

class FavoriteError extends FavoriteState {
  final String message;
  FavoriteError(this.message);
}

class FavoriteProvider extends ChangeNotifier {
  final FavoriteDb dbHelper;

  FavoriteProvider({required this.dbHelper});

  FavoriteState _state = FavoriteLoading();
  FavoriteState get state => _state;

  Future<void> loadFavorites() async {
    _state = FavoriteLoading();
    notifyListeners();

    try {
      final result = await dbHelper.getFavorites();
      _state = FavoriteLoaded(result);
    } catch (e) {
      _state = FavoriteError(e.toString());
    }
    notifyListeners();
  }

  Future<void> addFavorite(Restaurant resto) async {
    await dbHelper.insertFavorite(resto);
    await loadFavorites();
  }

  Future<void> removeFavorite(String id) async {
    await dbHelper.removeFavorite(id);
    await loadFavorites();
  }

  Future<bool> isFavorite(String id) async {
    return await dbHelper.isFavorite(id);
  }
}
