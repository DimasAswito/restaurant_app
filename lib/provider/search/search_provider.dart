import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../data/api/api_service.dart';
import '../../data/model/restaurant.dart';

class SearchProvider with ChangeNotifier {
  final ApiService apiService;
  SearchProvider({required this.apiService});

  bool isLoading = false;
  String message = "";
  List<Restaurant> restaurants = [];

  Future<void> searchRestaurant(String query) async {
    final q = query.trim();

    if (q.isEmpty) {
      restaurants = [];
      message = "";
      notifyListeners();
      return;
    }

    isLoading = true;
    message = "";
    notifyListeners();

    try {
      final results = await apiService.searchRestaurants(q);
      restaurants = results;
      if (restaurants.isEmpty) {
        message = 'Tidak ada hasil untuk "$q"';
      }
    } catch (e) {
      message = "Gagal memuat data";
      restaurants = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
