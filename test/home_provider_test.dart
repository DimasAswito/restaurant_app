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
      Restaurant(id: "1", name: "Restoran A", description: "Enak", city: "Jakarta", pictureId: "pic1", rating: 4.5),
      Restaurant(id: "2", name: "Restoran B", description: "Mantap", city: "Bandung", pictureId: "pic2", rating: 4.2),
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
