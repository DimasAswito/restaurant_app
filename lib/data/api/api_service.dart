import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/customer_review.dart';
import '../model/restaurant.dart';
import '../model/restaurant_detail.dart';

class ApiService {
  static const String baseUrl = "https://restaurant-api.dicoding.dev";

  Future<List<Restaurant>> getRestaurantList() async {
    final response = await http.get(Uri.parse("$baseUrl/list"));
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return RestaurantListResponse.fromJson(jsonBody).restaurants;
    } else {
      throw Exception("Failed to load restaurant list");
    }
  }

  Future<RestaurantDetail> getRestaurantDetail(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/detail/$id"));
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return RestaurantDetailResponse.fromJson(jsonBody).restaurant;
    } else {
      throw Exception("Failed to load restaurant detail");
    }
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    final q = Uri.encodeQueryComponent(query.trim());
    final response = await http.get(Uri.parse("$baseUrl/search?q=$q"));

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final List list = jsonBody['restaurants'] ?? [];
      return list.map<Restaurant>((e) => Restaurant.fromJson(e)).toList();
    } else {
      throw Exception("Failed to search restaurants");
    }
  }

  Future<List<CustomerReview>?> postReview({
    required String id,
    required String name,
    required String review,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/review"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id, "name": name, "review": review}),
    );

    if (response.statusCode == 201) {
      final result = jsonDecode(response.body);
      if (result['error'] == false) {
        final List reviews = result['customerReviews'];
        return reviews.map((e) => CustomerReview.fromJson(e)).toList();
      }
    }
    return null;
  }
}
