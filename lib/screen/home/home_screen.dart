import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/home/home_provider.dart';
import '../../data/api/api_service.dart';
import '../detail/detail_screen.dart';
import 'component/restaurant_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(apiService: ApiService())..fetchRestaurants(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Restoran",
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: Consumer<HomeProvider>(
          builder: (context, provider, _) {
            final state = provider.state;

            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeLoaded) {
              return ListView.builder(
                itemCount: state.restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = state.restaurants[index];
                  return RestaurantCard(
                    restaurant: restaurant,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(id: restaurant.id),
                        ),
                      );
                    },
                  );
                },
              );
            } else if (state is HomeError) {
              if (state.message.contains("SocketException")) {
                return const Center(
                  child: Text(
                    "Tidak ada koneksi internet",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                );
              }
              return Center(
                child: Text(
                  "Terjadi kesalahan: ${state.message}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
