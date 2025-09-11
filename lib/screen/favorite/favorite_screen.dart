import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/favorite/favorite_provider.dart';
import '../../data/db/favorite_db.dart';
import '../detail/detail_screen.dart';
import '../home/component/restaurant_card.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favorit",
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: ChangeNotifierProvider(
          create: (_) => FavoriteProvider(dbHelper: FavoriteDb())..loadFavorites(),
          child: Consumer<FavoriteProvider>(
            builder: (context, provider, _) {
              final state = provider.state;

              if (state is FavoriteLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is FavoriteLoaded) {
                if (state.favorites.isEmpty) {
                  return const Center(
                    child: Text("Belum ada restoran favorit"),
                  );
                }
                return ListView.builder(
                  itemCount: state.favorites.length,
                  itemBuilder: (context, index) {
                    final resto = state.favorites[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(id: resto.id),
                          ),
                        );
                      },
                      child: RestaurantCard(
                        restaurant: resto,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(id: resto.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              } else if (state is FavoriteError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}