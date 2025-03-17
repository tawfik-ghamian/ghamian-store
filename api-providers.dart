// lib/data/providers/auth_provider.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:ghamian_jewelry_app/core/network/dio_client.dart';
import 'package:ghamian_jewelry_app/core/constants/app_constants.dart';
import 'package:ghamian_jewelry_app/data/models/user_model.dart';

class AuthProvider extends GetxController {
  final _storage = GetStorage();
  final _dioClient = DioClient();
  
  User? user;
  
  bool get isLoggedIn => _storage.read('token') != null;
  
  String? get token => _storage.read('token');
  String? get userRole => _storage.read('userRole');
  String? get userBranchId => _storage.read('userBranchId');
  
  @override
  void onInit() {
    super.onInit();
    loadUserFromStorage();
  }
  
  void loadUserFromStorage() {
    final userData = _storage.read('user');
    if (userData != null) {
      try {
        user = User.fromJson(userData);
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }
  
  Future<bool> login(String username, String password) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: {
          'username': username,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userData = response.data['user'];
        
        _storage.write('token', token);
        _storage.write('user', userData);
        _storage.write('userRole', userData['role']);
        _storage.write('userBranchId', userData['branchId']);
        
        user = User.fromJson(userData);
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Login error: ${e.message}');
      return false;
    }
  }
  
  void logout() {
    _storage.erase();
    user = null;
    Get.offAllNamed('/login');
  }
}

// lib/data/providers/branch_provider.dart
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:ghamian_jewelry_app/core/network/dio_client.dart';
import 'package:ghamian_jewelry_app/core/constants/app_constants.dart';
import 'package:ghamian_jewelry_app/data/models/branch_model.dart';

class BranchProvider extends GetxController {
  final _dioClient = DioClient();
  final branches = <Branch>[].obs;
  final isLoading = false.obs;
  final error = RxString('');
  
  @override
  void onInit() {
    super.onInit();
    fetchBranches();
  }
  
  Future<void> fetchBranches() async {
    isLoading.value = true;
    error.value = '';
    
    try {
      final response = await _dioClient.get(ApiConstants.branches);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        branches.value = data.map((item) => Branch.fromJson(item)).toList();
      }
    } on DioException catch (e) {
      error.value = e.message ?? 'Failed to load branches';
      print('Branch fetch error: ${e.message}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<Branch?> getBranchById(String id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.branches}/$id');
      
      if (response.statusCode == 200) {
        return Branch.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('Get branch error: ${e.message}');
      return null;
    }
  }
}

// lib/data/providers/jewelry_provider.dart
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:ghamian_jewelry_app/core/network/dio_client.dart';
import 'package:ghamian_jewelry_app/core/constants/app_constants.dart';
import 'package:ghamian_jewelry_app/data/models/jewelry_model.dart';
import 'package:ghamian_jewelry_app/data/providers/auth_provider.dart';

class JewelryProvider extends GetxController {
  final _dioClient = DioClient();
  final jewelryItems = <Jewelry>[].obs;
  final isLoading = false.obs;
  final error = RxString('');
  
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  
  @override
  void onInit() {
    super.onInit();
    fetchJewelry();
  }
  
  Future<void> fetchJewelry({String? branchId, String? category, String? material}) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      final Map<String, dynamic> queryParams = {};
      
      // Add filters if provided
      if (branchId != null) queryParams['branchId'] = branchId;
      if (category != null) queryParams['category'] = category;
      if (material != null) queryParams['material'] = material;
      
      final response = await _dioClient.get(
        ApiConstants.jewelry,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        jewelryItems.value = data.map((item) => Jewelry.fromJson(item)).toList();
      }
    } on DioException catch (e) {
      error.value = e.message ?? 'Failed to load jewelry';
      print('Jewelry fetch error: ${e.message}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<Jewelry?> getJewelryById(String id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.jewelry}/$id');
      
      if (response.statusCode == 200) {
        return Jewelry.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('Get jewelry error: ${e.message}');
      return null;
    }
  }
  
  Future<bool> createJewelry(Jewelry jewelry) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.jewelry,
        data: jewelry.toJson(),
      );
      
      if (response.statusCode == 201) {
        await fetchJewelry();
        return true;
      }
      return false;
    } on DioException catch (e) {
      error.value = e.message ?? 'Failed to create jewelry';
      print('Create jewelry error: ${e.message}');
      return false;
    }
  }
  
  Future<bool> updateJewelry(String id, Jewelry jewelry) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.jewelry}/$id',
        data: jewelry.toJson(),
      );
      
      if (response.statusCode == 200) {
        await fetchJewelry();
        return true;
      }
      return false;
    } on DioException catch (e) {
      error.value = e.message ?? 'Failed to update jewelry';
      print('Update jewelry error: ${e.message}');
      return false;
    }
  }
  
  Future<bool> deleteJewelry(String id) async {
    try {
      final response = await _dioClient.delete('${ApiConstants.jewelry}/$id');
      
      if (response.statusCode == 200) {
        await fetchJewelry();
        return true;
      }
      return false;
    } on DioException catch (e) {
      error.value = e.message ?? 'Failed to delete jewelry';
      print('Delete jewelry error: ${e.message}');
      return false;
    }
  }
}

// lib/data/providers/transfer_provider.dart
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:ghamian_jewelry_app/core/network/dio_client.dart';
import 'package:ghamian_jewelry_app/core/constants/app_constants.dart';
import 'package:ghamian_jewelry_app/data/models/transfer_request_model.dart';

class TransferProvider extends GetxController {
  final _dioClient = DioClient();
  final transfers = <TransferRequest>[].obs;
  final isLoading = false.obs;
  final error = RxString('');
  
  @override
  void onInit() {
    super.onInit();
    fetchTransfers();
  }
  
  Future<void> fetchTransfers({String? status}) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      final Map<String, dynamic> queryParams = {};
      if (status != null) queryParams['status'] = status;
      
      final response = await _dioClient.get(
        ApiConstants.transfers,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        transfers.value = data.map((item) => TransferRequest.fromJson(item)).toList();
      }
    } on DioException catch (e) {
      error.value = e.message ?? 'Failed to load transfers';
      print('Transfer fetch error: ${e.message}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<TransferRequest?> getTransferById(String id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.transfers}/$id');
      
      if (response.statusCode == 200) {
        return TransferRequest.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('Get transfer error: ${e.message}');
      return null;
    }
  }
  
  Future<bool> createTransfer(TransferRequest transfer) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.transfers,
        data: transfer.toJson(),
      );
      
      if (response.statusCode == 201) {
        await fetchTransfers();
        return true;
      }
      return false;
    } on DioException catch (e) {
      error.value = e.message ?? 'Failed to create transfer request';
      print('Create transfer error: ${e.message}');
      return false;
    }
  }
  
  Future<bool> respondToTransfer(String id, String status) async {
    try {
      final response = await _dioClient.put(
        '${ApiConstants.transfers}/$id',
        data: {'status': status},
      );
      
      if (response.statusCode == 200) {
        await fetchTransfers();
        return true;
      }
      return false;
    } on DioException catch (e) {
      error.value = e.message ?? 'Failed to respond to transfer request';
      print('Transfer response error: ${e.message}');
      return false;
    }
  }
}
