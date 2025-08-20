import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/constants/order_status.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

class TableDisplayWidget extends ConsumerWidget {
  final String tableId;
  const TableDisplayWidget({super.key, required this.tableId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableAsync = ref.watch(getTableByIdProvider(tableId));
    return tableAsync.when(
      data: (table) => Text(
        'Table: ${table?.tableNumber}',
        style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black87),
      ),
      loading: () => Text('Table: $tableId'),
      error: (_, __) => Text('Table: $tableId'),
    );
  }
}

class AccountsDashboard extends HookConsumerWidget {
  const AccountsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(ordersProvider);
    
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF6B73FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced AppBar
              _buildEnhancedAppBar(context),
              
              Expanded(
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(parent: animationController, curve: Curves.easeOut),
                            ),
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: orderAsync.when(
                      data: (orders) {
                        final billsInProgress = orders.where(
                          (order) => order.status == OrderStatus.preparing.name || 
                                   order.status == OrderStatus.served.name
                        ).toList();

                        final billsPaid = orders.where(
                          (order) => order.status == OrderStatus.paid.name
                        ).toList();

                        return _buildAccountContent(billsInProgress, billsPaid, ref, context);
                      },
                      loading: () => _buildLoadingState(),
                      error: (error, stack) => _buildErrorState(error),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Hero(
            tag: 'back_button_accounts',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () => context.goNamed(AppRouteNames.adminDashboard),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          
          const Expanded(
            child: Text(
              'Accounts Dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountContent(
    List billsInProgress,
    List billsPaid,
    WidgetRef ref,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Bills in Progress',
                  billsInProgress.length,
                  Icons.pending_actions_rounded,
                  Colors.orange,
                  0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Bills Paid',
                  billsPaid.length,
                  Icons.check_circle_rounded,
                  Colors.green,
                  200,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Bills in Progress Section
          Expanded(
            child: _buildBillSection(
              'Bills in Progress',
              billsInProgress,
              Colors.orange,
              ref,
              context,
              showPayButton: true,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bills Paid Section
          Expanded(
            child: _buildBillSection(
              'Bills Paid',
              billsPaid,
              Colors.green,
              ref,
              context,
              showPayButton: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    int count,
    IconData icon,
    Color color,
    int delay,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(icon, color: color.withOpacity(0.7), size: 32),
                  const SizedBox(height: 12),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: color.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillSection(
    String title,
    List bills,
    Color color,
    WidgetRef ref,
    BuildContext context, {
    required bool showPayButton,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                showPayButton ? Icons.pending_rounded : Icons.check_circle_rounded,
                color: color.withOpacity(0.7),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Expanded(
          child: bills.isEmpty
              ? _buildEmptyState(
                  showPayButton ? 'No bills in progress' : 'No paid bills',
                  color,
                )
              : ListView.builder(
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    return _buildBillCard(
                      bills[index],
                      index,
                      color,
                      ref,
                      context,
                      showPayButton: showPayButton,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBillCard(
    dynamic order,
    int index,
    Color color,
    WidgetRef ref,
    BuildContext context, {
    required bool showPayButton,
  }) {
    final totalAmount = order.dishes.fold(0.0, (total, dish) => total + dish.price);
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      order.status == OrderStatus.preparing.name 
                          ? Icons.restaurant_rounded
                          : order.status == OrderStatus.served.name
                          ? Icons.room_service_rounded
                          : Icons.check_circle_rounded,
                      color: color.withOpacity(0.7),
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TableDisplayWidget(tableId: order.tableId),
                        const SizedBox(height: 4),
                        Text(
                          'Order: ${order.orderId.split('_').last.substring(0, 8)}...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Items: ${order.dishes.length} • Status: ${order.status.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '€${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color.withOpacity(0.7),
                        ),
                      ),
                      
                      if (showPayButton)
                        const SizedBox(height: 8),
                        
                      if (showPayButton)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green.shade400, Colors.green.shade600],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                try {
                                  final tableAsync = ref.watch(getTableByIdProvider(order.tableId));
                                  final updatedOrder = order.copyWith(status: OrderStatus.paid.name);
                                  
                                  await ref.read(updateOrderProvider(updatedOrder).future);
                                  await ref.read(updateOrderInTableProvider((
                                    tableNumber: tableAsync.value!.tableNumber,
                                    order: updatedOrder,
                                  )).future);
                                  
                                  ref.invalidate(getTableByNumberProvider(tableAsync.value!.tableNumber));
                                  await ref.read(updateOrderStatusProvider({
                                    'orderId': order.orderId,
                                    'status': OrderStatus.paid.name,
                                  }).future);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text('Order ${order.orderId.split('_').last.substring(0, 8)}... marked as paid!'),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
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
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(
                                  'Mark Paid',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 48,
            color: color.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: color.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading accounts data...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading orders: $error',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade600),
          ),
        ],
      ),
    );
  }
}
