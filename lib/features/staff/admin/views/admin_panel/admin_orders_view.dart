import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminOrdersView extends ConsumerWidget {
  const AdminOrdersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(ordersProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Orders View'
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
          onPressed: () {
            context.goNamed(AppRouteNames.adminPanel);
          },
        ),
      ),
      body: 
        orderAsync.when(data: (orders) {
          return ListView.builder(
            itemCount: orders.length, 
            itemBuilder: (context, index) {
              final order = orders[index];
              return GestureDetector(
                onTap: () {
                  context.goNamed(AppRouteNames.orderDetails, extra: order.orderId);
                },
                child: Card( 
                  child: ListTile(
                    title: Text(order.orderId),
                    subtitle: Text(order.status),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await ref.read(updateOrderStatusProvider({
                              'orderId': order.orderId,
                              'status': 'preparing'
                            }).future);
                          },
                          icon: const Icon(Icons.food_bank),
                        ),
                        IconButton(
                          onPressed: () async {
                            await ref.read(updateOrderStatusProvider({
                              'orderId': order.orderId,
                              'status': 'served'
                            }).future);
                          },
                          icon: const Icon(Icons.room_service),
                        ),
                        IconButton(
                          onPressed: () async {
                            await ref.read(updateOrderStatusProvider({
                              'orderId': order.orderId,
                              'status': 'paid'
                            }).future);
                          },
                          icon: const Icon(Icons.payments),
                        ),
                      ],
                    ),
                  )
                ),
              );
            });
        }, loading: () {
          return const Center(child: CircularProgressIndicator());
        }, error: (error, stackTrace) {
          return Center(child: Text('Error: $error'));
        }),
    );
  }
}