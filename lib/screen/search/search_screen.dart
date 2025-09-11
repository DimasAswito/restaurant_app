import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/search/search_provider.dart';
import '../../data/api/api_service.dart';
import '../home/component/restaurant_card.dart';
import '../detail/detail_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchProvider(apiService: ApiService()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Cari Restoran",
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: Consumer<SearchProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Cari restoran...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: provider.searchRestaurant,
                  ),
                ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.message.isNotEmpty &&
                            provider.restaurants.isEmpty
                      ? Center(child: Text(provider.message))
                      : ListView.builder(
                          itemCount: provider.restaurants.length,
                          itemBuilder: (ctx, index) {
                            final r = provider.restaurants[index];
                            return RestaurantCard(
                              restaurant: r,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailScreen(id: r.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
