// lib/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/modules/auth/views/login_view.dart';
import 'package:ghamian_jewelry_app/modules/auth/views/profile_view.dart';
import 'package:ghamian_jewelry_app/modules/home/views/home_view.dart';
import 'package:ghamian_jewelry_app/modules/inventory/views/jewelry_list_view.dart';
import 'package:ghamian_jewelry_app/modules/inventory/views/jewelry_detail_view.dart';
import 'package:ghamian_jewelry_app/modules/inventory/views/jewelry_add_view.dart';
import 'package:ghamian_jewelry_app/modules/branches/views/branch_list_view.dart';
import 'package:ghamian_jewelry_app/modules/transfers/views/transfer_list_view.dart';
import 'package:ghamian_jewelry_app/modules/transfers/views/create_transfer_view.dart';
import 'package:ghamian_jewelry_app/modules/auth/controllers/auth_middleware.dart';
import 'package:ghamian_jewelry_app/modules/auth/bindings/auth_binding.dart';
import 'package:ghamian_jewelry_app/modules/home/bindings/home_binding.dart';

abstract class Routes {
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const PROFILE = '/profile';
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
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileView(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: Routes.JEWELRY_LIST,
      page: () => JewelryListView(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: Routes.JEWELRY_DETAIL,
      page: () => JewelryDetailView(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: Routes.JEWELRY_ADD,
      page: () => JewelryAddView(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: Routes.BRANCHES,
      page: () => BranchListView(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: Routes.TRANSFERS,
      page: () => TransferListView(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    GetPage(
      name: Routes.TRANSFER_CREATE,
      page: () => CreateTransferView(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
  ];
}
