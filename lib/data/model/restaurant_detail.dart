import 'customer_review.dart';

class RestaurantDetail {
  final String id;
  final String name;
  final String description;
  final String city;
  final String address;
  final String pictureId;
  final double rating;
  final List<Category> categories;
  final Menu menus;

  final List<CustomerReview> customerReviews;

  RestaurantDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.address,
    required this.pictureId,
    required this.rating,
    required this.categories,
    required this.menus,
    required this.customerReviews,
  });

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    return RestaurantDetail(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      city: json['city'],
      address: json['address'],
      pictureId: json['pictureId'],
      rating: (json['rating'] as num).toDouble(),
      categories: List<Category>.from(
        json['categories'].map((x) => Category.fromJson(x)),
      ),
      menus: Menu.fromJson(json['menus']),
      customerReviews:
          (json['customerReviews'] as List?)
              ?.map((e) => CustomerReview.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Category {
  final String name;
  Category({required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json['name']);
  }
}

class Menu {
  final List<MenuItem> foods;
  final List<MenuItem> drinks;

  Menu({required this.foods, required this.drinks});

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      foods: List<MenuItem>.from(
        json['foods'].map((x) => MenuItem.fromJson(x)),
      ),
      drinks: List<MenuItem>.from(
        json['drinks'].map((x) => MenuItem.fromJson(x)),
      ),
    );
  }
}

class MenuItem {
  final String name;
  MenuItem({required this.name});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(name: json['name']);
  }
}

class RestaurantDetailResponse {
  final bool error;
  final String message;
  final RestaurantDetail restaurant;

  RestaurantDetailResponse({
    required this.error,
    required this.message,
    required this.restaurant,
  });

  factory RestaurantDetailResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantDetailResponse(
      error: json['error'],
      message: json['message'],
      restaurant: RestaurantDetail.fromJson(json['restaurant']),
    );
  }
}
