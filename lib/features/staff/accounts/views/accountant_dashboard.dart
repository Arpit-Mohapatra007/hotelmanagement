import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/router.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

// Helper widget to display table number from table ID
class TableDisplayWidget extends ConsumerWidget {
  final String tableId;
  const TableDisplayWidget({super.key, required this.tableId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableAsync = ref.watch(getTableByIdProvider(tableId));
    
    return tableAsync.when(
      data: (table) => Text('Table: ${table?.tableNumber ?? tableId}'),
      loading: () => Text('Table: $tableId'),
      error: (_, __) => Text('Table: $tableId'),
    );
  }
}

class AccountsDashboard extends ConsumerWidget {
  const AccountsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(ordersProvider);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white,
          onPressed: () {
            context.goNamed(AppRouteNames.adminDashboard);
          },
        ),
        title: const Text('Accounts Dashboard'),
      ),
      body: orderAsync.when(
        data: (orders) {
          // Filter orders for Bills in Progress (preparing or served)
          final billsInProgress = orders.where(
            (order) => order.status == 'preparing' || order.status == 'served'
          ).toList();
          
          // Filter orders for Bills Paid
          final billsPaid = orders.where(
            (order) => order.status == 'paid'
          ).toList();
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bills in Progress Section
                Text(
                  'Bills in Progress (${billsInProgress.length})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  flex: 1,
                  child: billsInProgress.isEmpty
                      ? const Center(
                          child: Text(
                            'No bills in progress',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: billsInProgress.length,
                          itemBuilder: (context, index) {
                            final order = billsInProgress[index];
                            final totalAmount = order.dishes.fold(
                              0.0, (total, dish) => total + dish.price
                            );
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: order.status == 'preparing' 
                                      ? Colors.orange 
                                      : Colors.green,
                                  child: Text(
                                    order.status == 'preparing' ? 'P' : 'S',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: TableDisplayWidget(tableId: order.tableId),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Order ID: ${order.orderId}'),
                                    Text('Status: ${order.status.toUpperCase()}'),
                                    Text('Items: ${order.dishes.length}'),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '€${totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            await ref.read(
                                              updateOrderStatusProvider({
                                                'orderId': order.orderId,
                                                'status': 'paid'
                                              }).future
                                            );
                                            
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Order ${order.orderId} marked as paid!'
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Error: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4
                                          ),
                                        ),
                                        child: const Text('Paid'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                // Bills Paid Section
                Text(
                  'Bills Paid (${billsPaid.length})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  flex: 1,
                  child: billsPaid.isEmpty
                      ? const Center(
                          child: Text(
                            'No paid bills',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: billsPaid.length,
                          itemBuilder: (context, index) {
                            final order = billsPaid[index];
                            final totalAmount = order.dishes.fold(
                              0.0, (total, dish) => total + dish.price
                            );
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: const Color.fromARGB(255, 0, 0, 0),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                ),
                                title: TableDisplayWidget(tableId: order.tableId),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Order ID: ${order.orderId}'),
                                    Text('Status: PAID'),
                                    Text('Items: ${order.dishes.length}'),
                                  ],
                                ),
                                trailing: Text(
                                  '€${totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading orders: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}