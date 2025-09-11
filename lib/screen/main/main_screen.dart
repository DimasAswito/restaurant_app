import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/main/main_provider.dart';
import '../favorite/favorite_screen.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../setting/setting_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<Widget> _screens = const [HomeScreen(), SearchScreen(), FavoriteScreen(), SettingScreen()];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MainProvider>();

    return Scaffold(
      body: _screens[provider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: provider.currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: provider.setIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }
}
