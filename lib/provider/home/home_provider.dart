import 'package:flutter/material.dart';
import '../../data/api/api_service.dart';
import '../../data/model/restaurant.dart';

sealed class HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Restaurant> restaurants;
  HomeLoaded(this.restaurants);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeProvider extends ChangeNotifier {
  final ApiService apiService;

  HomeProvider({required this.apiService});

  HomeState _state = HomeLoading();
  HomeState get state => _state;

  Future<void> fetchRestaurants() async {
    _state = HomeLoading();
    notifyListeners();

    try {
      final result = await apiService.getRestaurantList();
      _state = HomeLoaded(result);
    } catch (e) {
      _state = HomeError(e.toString());
    }

    notifyListeners();
  }
}
