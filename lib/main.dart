import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/favorite/favorite_provider.dart';
import 'package:restaurant_app/provider/setting/setting_provider.dart';
import 'data/db/favorite_db.dart';
import 'screen/main/main_screen.dart';
import 'style/theme/app_theme.dart';
import 'provider/main/main_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainProvider()),
        ChangeNotifierProvider(create: (_) => SettingProvider()),
        ChangeNotifierProvider(create: (_) =>FavoriteProvider(dbHelper: FavoriteDb())..loadFavorites(),
        ),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingProvider>(
      builder: (context, setting, _) {
        return MaterialApp(
          title: 'Restaurant App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: setting.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          home: const MainScreen(),
        );
      },
    );
  }
}
