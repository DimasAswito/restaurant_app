import 'package:flutter/material.dart';
import '../../data/api/api_service.dart';
import '../../data/model/restaurant_detail.dart';

sealed class DetailState {}

class DetailLoading extends DetailState {}

class DetailLoaded extends DetailState {
  final RestaurantDetail restaurant;
  DetailLoaded(this.restaurant);
}

class DetailError extends DetailState {
  final String message;
  DetailError(this.message);
}

class DetailProvider extends ChangeNotifier {
  final ApiService apiService;
  DetailState _state = DetailLoading();
  DetailState get state => _state;

  DetailProvider({required this.apiService});

  Future<void> fetchDetail(String id) async {
    _state = DetailLoading();
    notifyListeners();

    try {
      final result = await apiService.getRestaurantDetail(id);
      _state = DetailLoaded(result);
    } catch (e) {
      _state = DetailError(e.toString());
    }

    notifyListeners();
  }

  Future<bool> addReview(String id, String name, String review) async {
    try {
      final success = await apiService.postReview(
        id: id,
        name: name,
        review: review,
      );
      if (success != null) {
        await fetchDetail(id);
      }
      return success != null;
    } catch (_) {
      return false;
    }
  }
}
