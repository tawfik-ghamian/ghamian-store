// Project Structure:
// lib/
//  ├── main.dart
//  ├── core/
//  │   ├── constants/
//  │   ├── network/
//  │   └── utils/
//  ├── data/
//  │   ├── models/
//  │   ├── providers/
//  │   └── repositories/
//  ├── modules/
//  │   ├── auth/
//  │   ├── branches/
//  │   ├── inventory/
//  │   └── transfers/
//  └── routes/

// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ghamian_jewelry_app/routes/app_pages.dart';
import 'package:ghamian_jewelry_app/core/constants/app_constants.dart';
import 'package:ghamian_jewelry_app/data/providers/auth_provider.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final authProvider = Get.put(AuthProvider());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ghamian Jewelry Store',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.amber[700],
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[800],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: authProvider.isLoggedIn ? Routes.HOME : Routes.LOGIN,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
    );
  }
}
