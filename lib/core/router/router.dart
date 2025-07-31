import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmanagement/features/authentication/views/login.dart';
import 'package:hotelmanagement/features/authentication/views/table_login.dart';
import 'package:hotelmanagement/features/customer/views/bill.dart';
import 'package:hotelmanagement/features/customer/views/customer_dashboard.dart';
import 'package:hotelmanagement/features/customer/views/customer_cart.dart';
import 'package:hotelmanagement/features/customer/views/order_status.dart';
import 'package:hotelmanagement/features/staff/accounts/views/accountant_dashboard.dart';
import 'package:hotelmanagement/features/staff/admin/views/admin_dashboard.dart';
import 'package:hotelmanagement/features/staff/chef/views/chef_dashboard.dart';
import 'package:hotelmanagement/features/staff/inventory/views/inventory_dashboard.dart';
import 'package:hotelmanagement/features/staff/waiter/views/waiter_dashboard.dart';
import 'package:hotelmanagement/home.dart';

// Define route names for easy access
class AppRouteNames {
  // These should be the actual 'name' strings used in GoRoute
  static const String customerDashboard = 'customerDashboard';
  static const String customerCart = 'customerCart';
  static const String orderStatus = 'orderStatus'; 
  static const String bill = 'bill';
  static const String login = 'login';
  static const String tableLogin = 'tableLogin';
  static const String home = 'home';
  static const String adminDashboard = 'adminDashboard';
  static const String waiterDashboard = 'waiterDashboard';
  static const String accountsDashboard = 'accountsDashboard';
  static const String chefDashboard = 'chefDashboard';
  static const String inventoryDashboard = 'inventoryDashboard';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // The initial location in the app
    initialLocation: '/', 
    routes: [
      GoRoute(
        path: '/customer-dashboard/:tableNumber', 
        name: AppRouteNames.customerDashboard, 
        builder: (context, state) {
          final tableNumber = state.pathParameters['tableNumber'];
          return CustomerDashboard(tableNumber: tableNumber!);
        },
        routes: [
          GoRoute(
            path: 'cart',
            name: AppRouteNames.customerCart,
            builder: (context, state) {
              final tableNumber = state.pathParameters['tableNumber'];
              return CustomerCart(tableNumber: tableNumber!);
            },
          ),
          GoRoute(
            path: 'order-status',
            name: AppRouteNames.orderStatus,
            builder: (context, state) {
              final tableNumber = state.pathParameters['tableNumber'];
              return OrderStatus(tableNumber: tableNumber!);
            },
          ),
          GoRoute(path: 'bill',
            name: AppRouteNames.bill,
            builder: (context, state){
              final tableNumber = state.pathParameters['tableNumber'];
              return BillView(tableNumber: tableNumber!);
            }
            ),
        ],
      ),
      GoRoute(path: '/',
        name: AppRouteNames.home,
        builder: (context, state) {
          return const HomePage();
        },
        ),
      GoRoute(path: '/login',
        name: AppRouteNames.login,
        builder: (context, state) {
          return const LoginPage();
        },
        ),
        GoRoute(path: '/tableLogin',
        name: AppRouteNames.tableLogin,
        builder: (context, state) {
          return const TableLogin();
        },
        ),
        GoRoute(path: '/waiterDashboard',
        name: AppRouteNames.waiterDashboard,
        builder: (context, state) {
          return const WaiterDashboard();
        },
        ),
        GoRoute(path: '/accountsDashboard',
        name: AppRouteNames.accountsDashboard,
        builder: (context, state) {
          return const AccountsDashboard();
        },
        ),
        GoRoute(path: '/chefDashboard',
        name: AppRouteNames.chefDashboard,
        builder: (context, state) {
          return const ChefDashboard();
        },
        ),
        GoRoute(path: '/inventoryDashboard',
        name: AppRouteNames.inventoryDashboard,
        builder: (context, state){
          return const InventoryDashboard();
        },
        ),
        GoRoute(path: '/adminDashboard',
        name: AppRouteNames.adminDashboard,
        builder: (context, state) {
          return const AdminDashboard();
        },
        )
    ],
  );
});