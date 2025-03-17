// lib/modules/auth/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/data/providers/auth_provider.dart';
import 'package:ghamian_jewelry_app/routes/app_pages.dart';

class LoginController extends GetxController {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  
  final obscureText = true.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }
  
  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    errorMessage.value = '';
    isLoading.value = true;
    
    try {
      final success = await _authProvider.login(
        usernameController.text.trim(),
        passwordController.text,
      );
      
      if (success) {
        Get.offAllNamed(Routes.HOME);
      } else {
        errorMessage.value = 'Invalid credentials. Please try again.';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again later.';
      print('Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

// lib/modules/auth/controllers/auth_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/data/providers/auth_provider.dart';
import 'package:ghamian_jewelry_app/routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  
  @override
  RouteSettings? redirect(String? route) {
    // If not logged in, redirect to login
    if (!_authProvider.isLoggedIn && route != Routes.LOGIN) {
      return RouteSettings(name: Routes.LOGIN);
    }
    
    // If already logged in and trying to access login page, redirect to home
    if (_authProvider.isLoggedIn && route == Routes.LOGIN) {
      return RouteSettings(name: Routes.HOME);
    }
    
    // Role-based access control
    if (_authProvider.userRole == 'manager') {
      // Managers can access all pages
      return null;
    } else if (_authProvider.userRole == 'staff') {
      // Staff can access only specific pages
      if (route?.contains('/admin') == true) {
        return RouteSettings(name: Routes.HOME);
      }
    }
    
    return null;
  }
}

// lib/modules/auth/views/profile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/data/providers/auth_provider.dart';

class ProfileView extends StatelessWidget {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  
  @override
  Widget build(BuildContext context) {
    final user = _authProvider.user;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.amber[200],
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.amber[800],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Name', user?.name ?? 'N/A'),
                      Divider(),
                      _buildInfoRow('Username', user?.username ?? 'N/A'),
                      Divider(),
                      _buildInfoRow('Role', _formatRole(user?.role ?? 'N/A')),
                      if (user?.branchId != null) ...[
                        Divider(),
                        _buildInfoRow('Branch ID', user!.branchId!),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _authProvider.logout,
                icon: Icon(Icons.logout),
                label: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatRole(String role) {
    return role.isNotEmpty ? role[0].toUpperCase() + role.substring(1) : role;
  }
}

// lib/modules/auth/bindings/auth_binding.dart
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/data/providers/auth_provider.dart';
import 'package:ghamian_jewelry_app/modules/auth/controllers/login_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
