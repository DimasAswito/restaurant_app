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

  test('State awal harus didefinisikan', () {
    expect(searchProvider.isLoading, false);
    expect(searchProvider.message, "");
    expect(searchProvider.restaurants, []);
  });

  test('Harus mengembalikan daftar restoran ketika API berhasil', () async {
    final mockRestaurants = [
      Restaurant(
        id: "1",
        name: "Restoran A",
        description: "Enak",
        city: "Jakarta",
        pictureId: "pic1",
        rating: 4.5,
      ),
      Restaurant(
        id: "2",
        name: "Restoran B",
        description: "Mantap",
        city: "Bandung",
        pictureId: "pic2",
        rating: 4.2,
      ),
    ];

    when(() => mockApiService.searchRestaurants("resto"))
        .thenAnswer((_) async => mockRestaurants);

    // Act
    await searchProvider.searchRestaurant("resto");

    // Assert
    expect(searchProvider.isLoading, false);
    expect(searchProvider.restaurants, equals(mockRestaurants));
    expect(searchProvider.message, isEmpty);
  });

  test('Harus mengembalikan error ketika API gagal', () async {
    // Arrange
    when(() => mockApiService.searchRestaurants("resto"))
        .thenThrow(Exception("API Error"));

    // Act
    await searchProvider.searchRestaurant("resto");

    // Assert
    expect(searchProvider.isLoading, false);
    expect(searchProvider.restaurants, isEmpty);
    expect(searchProvider.message, equals("Gagal memuat data"));
  });

  test('Jika query kosong, harus reset state tanpa error', () async {
    // Act
    await searchProvider.searchRestaurant("");

    // Assert
    expect(searchProvider.restaurants, isEmpty);
    expect(searchProvider.message, "");
    expect(searchProvider.isLoading, false);
  });
}
