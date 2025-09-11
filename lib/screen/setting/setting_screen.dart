import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/setting/setting_provider.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pengaturan",
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Consumer<SettingProvider>(
        builder: (context, provider, _) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text("Mode Malam"),
                value: provider.isDarkTheme,
                onChanged: (value) {
                  provider.toggleTheme(value);
                },
                activeColor: Colors.green,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.shade400,
              ),
              SwitchListTile(
                title: const Text("Notifikasi Makan Siang"),
                value: provider.isReminderActive,
                onChanged: (value) {
                  provider.toggleReminder(value);
                },
                activeColor: Colors.green,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.shade400,
              ),
            ],
          );
        },
      ),
    );
  }
}
