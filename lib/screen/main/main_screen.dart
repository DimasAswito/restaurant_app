import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/main/main_provider.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<Widget> _screens = const [HomeScreen(), SearchScreen()];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MainProvider>();

    return Scaffold(
      body: _screens[provider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: provider.currentIndex,
        onTap: provider.setIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}
