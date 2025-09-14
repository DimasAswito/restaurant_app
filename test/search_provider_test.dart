import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/data/model/restaurant.dart';
import 'package:restaurant_app/provider/search/search_provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late SearchProvider searchProvider;

  setUp(() {
    mockApiService = MockApiService();
    searchProvider = SearchProvider(apiService: mockApiService);
  });

  test('State Search awal harus ada', () {
    expect(searchProvider.isLoading, false);
    expect(searchProvider.message, "");
    expect(searchProvider.restaurants, []);
  });

  test('Harus mengembalikan daftar restoran ketika API berhasil', () async {
    final mockRestaurants = [
      Restaurant(id: "rqdv5juczeskfw1e867", name: "Melting Pot", description: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. ...", city: "Medan", pictureId: "https://restaurant-api.dicoding.dev/images/small/14", rating: 4.2),
    ];

    when(() => mockApiService.searchRestaurants("resto"))
        .thenAnswer((_) async => mockRestaurants);

    await searchProvider.searchRestaurant("resto");

    expect(searchProvider.isLoading, false);
    expect(searchProvider.restaurants, equals(mockRestaurants));
    expect(searchProvider.message, isEmpty);
  });

  test('Harus mengembalikan error ketika API gagal', () async {
    when(() => mockApiService.searchRestaurants("resto"))
        .thenThrow(Exception("API Error"));

    await searchProvider.searchRestaurant("resto");

    expect(searchProvider.isLoading, false);
    expect(searchProvider.restaurants, isEmpty);
    expect(searchProvider.message, equals("Gagal memuat data"));
  });

  test('Jika query kosong, harus reset state tanpa error', () async {
    await searchProvider.searchRestaurant("");

    expect(searchProvider.restaurants, isEmpty);
    expect(searchProvider.message, "");
    expect(searchProvider.isLoading, false);
  });
}
