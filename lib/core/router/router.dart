import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmanagement/features/customer/views/bill.dart';
import 'package:hotelmanagement/features/customer/views/customer_dashboard.dart';
import 'package:hotelmanagement/features/customer/views/customer_cart.dart';
import 'package:hotelmanagement/features/customer/views/order_status.dart';

// Define route names for easy access
class AppRouteNames {
  // These should be the actual 'name' strings used in GoRoute
  static const String customerDashboard = 'customerDashboard';
  static const String customerCart = 'customerCart';
  static const String orderStatus = 'orderStatus'; 
  static const String bill = 'bill';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // The initial location in the app
    initialLocation: '/customer-dashboard/T001', 
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
            )
        ],
      ),
    ],
  );
});