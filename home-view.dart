// lib/modules/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/modules/home/controllers/home_controller.dart';
import 'package:ghamian_jewelry_app/routes/app_pages.dart';
import 'package:ghamian_jewelry_app/data/providers/auth_provider.dart';

class HomeView extends StatelessWidget {
  final controller = Get.put(HomeController());
  final authProvider = Get.find<AuthProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Text(
              'Welcome, ${authProvider.user?.name ?? "User"}!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Role: ${authProvider.user?.role ?? "Staff"}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 24),

            // Dashboard cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    title: 'Inventory',
                    icon: Icons.inventory,
                    color: Colors.blue,
                    onTap: () => Get.toNamed(Routes.JEWELRY_LIST),
                  ),
                  _buildDashboardCard(
                    title: 'Branches',
                    icon: Icons.store,
                    color: Colors.green,
                    onTap: () => Get.toNamed(Routes.BRANCHES),
                  ),
                  _buildDashboardCard(
                    title: 'Transfers',
                    icon: Icons.swap_horiz,
                    color: Colors.orange,
                    onTap: () => Get.toNamed(Routes.TRANSFERS),
                  ),
                  _buildDashboardCard(
                    title: 'Statistics',
                    icon: Icons.bar_chart,
                    color: Colors.purple,
                    onTap: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Statistics module is under development',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/modules/home/controllers/home_controller.dart
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/data/providers/auth_provider.dart';

class HomeController extends GetxController {
  final AuthProvider _authProvider = Get.find<AuthProvider>();

  String get userName => _authProvider.user?.name ?? "User";
  String get userRole => _authProvider.user?.role ?? "Staff";
  String? get userBranch => _authProvider.userBranchId;
}
