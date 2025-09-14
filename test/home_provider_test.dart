import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/data/model/restaurant.dart';
import 'package:restaurant_app/provider/home/home_provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late HomeProvider homeProvider;

  setUp(() {
    mockApiService = MockApiService();
    homeProvider = HomeProvider(apiService: mockApiService);
  });

  test('State awal harus HomeLoading', () {
    expect(homeProvider.state, isA<HomeLoading>());
  });

  test('Harus mengembalikan daftar restoran ketika API berhasil', () async {
    final mockRestaurants = [
      Restaurant(id: "rqdv5juczeskfw1e867", name: "Melting Pot", description: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. ...", city: "Medan", pictureId: "https://restaurant-api.dicoding.dev/images/small/14", rating: 4.2),
    ];

    when(() => mockApiService.getRestaurantList())
        .thenAnswer((_) async => mockRestaurants);

    await homeProvider.fetchRestaurants();

    expect(homeProvider.state, isA<HomeLoaded>());
    final state = homeProvider.state as HomeLoaded;
    expect(state.restaurants, equals(mockRestaurants));
  });

  test('Harus mengembalikan error ketika API gagal', () async {
    when(() => mockApiService.getRestaurantList())
        .thenThrow(Exception('API Error'));

    await homeProvider.fetchRestaurants();

    expect(homeProvider.state, isA<HomeError>());
    final state = homeProvider.state as HomeError;
    expect(state.message, contains('API Error'));
  });
}
