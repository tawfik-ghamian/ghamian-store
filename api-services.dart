// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ghamian_jewelry_app/core/constants/app_constants.dart';

class DioClient {
  final Dio _dio = Dio();
  final _storage = GetStorage();

  DioClient() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.responseType = ResponseType.json;

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        // Add auth token to requests if available
        final token = _storage.read('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) {
        if (error.response?.statusCode == 401) {
          // Handle token expiration, logout user
          _storage.erase();
          // You would redirect to login here using GetX routing
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}

// lib/core/constants/app_constants.dart
class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Using Android emulator localhost
  
  // Auth endpoints
  static const String login = '/login';
  
  // Branch endpoints
  static const String branches = '/branches';
  
  // Jewelry endpoints
  static const String jewelry = '/jewelry';
  
  // Transfer endpoints
  static const String transfers = '/transfer-requests';
}

class AppConstants {
  static const String appName = 'Ghamian Jewelry';
  static const List<String> jewelryCategories = ['Ring', 'Necklace', 'Bracelet', 'Earring', 'Watch', 'Pendant'];
  static const List<String> materials = ['Gold', 'Silver', 'Platinum', 'Diamond', 'Pearl', 'Ruby', 'Sapphire', 'Emerald'];
}

// lib/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/modules/auth/views/login_view.dart';
import 'package:ghamian_jewelry_app/modules/home/views/home_view.dart';
import 'package:ghamian_jewelry_app/modules/inventory/views/jewelry_list_view.dart';
import 'package:ghamian_jewelry_app/modules/inventory/views/jewelry_detail_view.dart';
import 'package:ghamian_jewelry_app/modules/branches/views/branch_list_view.dart';
import 'package:ghamian_jewelry_app/modules/transfers/views/transfer_list_view.dart';
import 'package:ghamian_jewelry_app/modules/transfers/views/create_transfer_view.dart';

abstract class Routes {
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const JEWELRY_LIST = '/jewelry';
  static const JEWELRY_DETAIL = '/jewelry/:id';
  static const JEWELRY_ADD = '/jewelry/add';
  static const BRANCHES = '/branches';
  static const TRANSFERS = '/transfers';
  static const TRANSFER_CREATE = '/transfers/create';
}

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
    ),
    GetPage(
      name: Routes.JEWELRY_LIST,
      page: () => JewelryListView(),
    ),
    GetPage(
      name: Routes.JEWELRY_DETAIL,
      page: () => JewelryDetailView(),
    ),
    GetPage(
      name: Routes.JEWELRY_ADD,
      page: () => JewelryAddView(),
    ),
    GetPage(
      name: Routes.BRANCHES,
      page: () => BranchListView(),
    ),
    GetPage(
      name: Routes.TRANSFERS,
      page: () => TransferListView(),
    ),
    GetPage(
      name: Routes.TRANSFER_CREATE,
      page: () => CreateTransferView(),
    ),
  ];
}
