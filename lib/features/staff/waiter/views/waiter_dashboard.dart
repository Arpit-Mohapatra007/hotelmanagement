import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/router.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

class WaiterDashboard extends ConsumerWidget {
  const WaiterDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
          onPressed: () {
            context.goNamed(AppRouteNames.adminDashboard);
          },
        ),
        title: const Text('Waiter Dashboard'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.topLeft,
              width: MediaQuery.of(context).size.width * 0.9,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ref.watch(getTotalTipsStreamProvider).when(
                data: (totalTips) => Text(
                  'Total Tips Collected: €${totalTips.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
                loading: () => const Text(
                  'Loading tips...',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
                error: (error, stack) => Text(
                  'Error loading tips: $error',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Text(
              'Orders',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: ordersAsync.when(
                data: (orders){
                  if(orders.isEmpty){
                    return const Center(child: Text('No orders available.'));
                  }
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index){
                      final order = orders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        elevation: 2.0,
                        child: ListTile(
                          title: Text(
                            'Order ID: ${order.orderId}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Status: ${order.status}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: order.status == 'preparing'
                              ? const Icon(Icons.arrow_forward_ios)
                              : const Icon(Icons.close),
                          onTap: () {
                            order.status == 'preparing'?
                              context.goNamed(
                                AppRouteNames.orderDetails,
                                pathParameters: {'orderId': order.orderId},
                              ) : null;
                          }
                           )
                          
                      );
                    }
                      );
                }, 
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                )
              )
          ],
        ),
      ),
    );
  }
}
