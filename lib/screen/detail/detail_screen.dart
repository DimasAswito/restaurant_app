import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/model/restaurant.dart';
import 'package:restaurant_app/provider/favorite/favorite_provider.dart';
import '../../provider/detail/detail_provider.dart';
import '../../data/api/api_service.dart';
import 'component/menu_card.dart';
import 'component/review_dialog.dart';

class DetailScreen extends StatelessWidget {
  final String id;
  final Restaurant? localRestaurant;
  const DetailScreen({super.key, required this.id, this.localRestaurant});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = DetailProvider(apiService: ApiService());
        if (localRestaurant == null) {
          provider.fetchDetail(id);
        } else {
          provider.setFromLocal(localRestaurant!);
        }
        return provider;
      },
      child: Scaffold(
        body: Consumer2<DetailProvider, FavoriteProvider>(
          builder: (context, detailProvider, favProvider, _) {
            final state = detailProvider.state;

            if (state is DetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DetailLoaded) {
              final resto = state.restaurant;
              final isFavoriteFuture = favProvider.isFavorite(resto.id);

              return FutureBuilder<bool>(
                future: isFavoriteFuture,
                builder: (context, snapshot) {
                  final isFavorite = snapshot.data ?? false;

                  return Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeInImage.assetNetwork(
                              placeholder: 'assets/images/placeholder.png',
                              image: "https://restaurant-api.dicoding.dev/images/medium/${resto.pictureId}",
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Image.asset('assets/images/placeholder.png', fit: BoxFit.cover);
                              },
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                resto.name,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "${resto.address}, ${resto.city}",
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 18,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        resto.rating.toString(),
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "Ulasan",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (resto.customerReviews.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "Belum ada review",
                                  style: TextStyle(fontFamily: 'Inter'),
                                ),
                              )
                            else
                              ...resto.customerReviews.map(
                                (r) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: Card(
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.green,
                                        child: Text(
                                          (r.name.isNotEmpty ? r.name[0] : '?')
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        r.name,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        r.review,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      trailing: Text(
                                        r.date,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                resto.description,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "Menu",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    resto.menus.foods.length +
                                    resto.menus.drinks.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                itemBuilder: (context, index) {
                                  final foods = resto.menus.foods;
                                  final drinks = resto.menus.drinks;
                                  final allMenus = [...foods, ...drinks];
                                  final item = allMenus[index];
                                  final isFood = index < foods.length;

                                  return MenuCard(item: item, isFood: isFood);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              if (isFavorite) {
                                await favProvider.removeFavorite(resto.id);
                              } else {
                                await favProvider.addFavorite(
                                  Restaurant(
                                    id: resto.id,
                                    name: resto.name,
                                    description: resto.description,
                                    pictureId: resto.pictureId,
                                    city: resto.city,
                                    rating: resto.rating,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else if (state is DetailError) {
              String displayMessage;

              if (state.message.toLowerCase().contains("failed host lookup") ||
                  state.message.toLowerCase().contains("socketexception")) {
                displayMessage =
                    "Tidak dapat terhubung ke server. Periksa koneksi internet Anda.";
              } else if (state.message.toLowerCase().contains("api") ||
                  state.message.toLowerCase().contains("server")) {
                displayMessage =
                    "Gagal mengambil data dari server. Silakan coba lagi.";
              } else {
                displayMessage = "Terjadi kesalahan, silakan coba lagi.";
              }

              return Center(
                child: Text(
                  displayMessage,
                  style: const TextStyle(fontFamily: 'Inter'),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const SizedBox();
          },
        ),
        floatingActionButton: Consumer<DetailProvider>(
          builder: (context, provider, _) {
            if (provider.state is DetailLoaded) {
              final resto = (provider.state as DetailLoaded).restaurant;
              return FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ReviewDialog(
                      onSubmit: (name, review) =>
                          provider.addReview(resto.id, name, review),
                    ),
                  );
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.rate_review),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
