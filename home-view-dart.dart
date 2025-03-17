// lib/modules/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/data/providers/auth_provider.dart';
import 'package:ghamian_jewelry_app/routes/app_pages.dart';

class HomeView extends StatelessWidget {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ghamian Jewelry'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildActionGrid(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildWelcomeCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.waving_hand,
                  color: Colors.amber[700],
                  size: 32,
                ),
                SizedBox(width: 12),
                Text(
                  'Welcome, ${_authProvider.user?.name ?? 'User'}!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Role: ${_formatRole(_authProvider.userRole ?? 'User')}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
            if (_authProvider.userBranchId != null) ...[
              SizedBox(height: 4),
              Text(
                'Branch ID: ${_authProvider.userBranchId}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionGrid() {
    final actionItems = [
      _ActionItem(
        title: 'Inventory',
        icon: Icons.diamond,
        onTap: () => Get.toNamed(Routes.JEWELRY_LIST),
        color: Colors.blue,
      ),
      _ActionItem(
        title: 'Branches',
        icon: Icons.store,
        onTap: () => Get.toNamed(Routes.BRANCHES),
        color: Colors.green,
      ),
      _ActionItem(
        title: 'Transfers',
        icon: Icons.compare_arrows,
        onTap: () => Get.toNamed(Routes.TRANSFERS),
        color: Colors.purple,
      ),
      _ActionItem(
        title: 'Add Item',
        icon: Icons.add_circle,
        onTap: () => Get.toNamed(Routes.JEWELRY_ADD),
        color: Colors.orange,
      ),
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: actionItems.length,
      itemBuilder: (context, index) {
        final item = actionItems[index];
        return _buildActionItem(item);
      },
    );
  }
  
  Widget _buildActionItem(_ActionItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: item.color.withOpacity(0.1),
          border: Border.all(
            color: item.color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 40,
              color: item.color,
            ),
            SizedBox(height: 12),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatRole(String role) {
    return role.isNotEmpty ? role[0].toUpperCase() + role.substring(1) : role;
  }
}

class _ActionItem {
  final String title;
  final IconData icon;
  final Function() onTap;
  final Color color;
  
  _ActionItem({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.color,
  });
}

// lib/modules/home/bindings/home_binding.dart
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/data/providers/auth_provider.dart';
import 'package:ghamian_jewelry_app/data/providers/branch_provider.dart';
import 'package:ghamian_jewelry_app/data/providers/jewelry_provider.dart';
import 'package:ghamian_jewelry_app/data/providers/transfer_provider.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<BranchProvider>(() => BranchProvider());
    Get.lazyPut<JewelryProvider>(() => JewelryProvider());
    Get.lazyPut<TransferProvider>(() => TransferProvider());
  }
}
