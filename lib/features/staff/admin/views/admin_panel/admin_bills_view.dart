import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/constants/order_status.dart';
import 'package:hotelmanagement/core/models/order.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/order/order_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

// Safe opacity extension
extension ColorExtensions on Color {
  Color withOpacityFactor(double opacity) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return withAlpha((safeOpacity * 255).round());
  }
}

// Helper widget to display table number from table ID
class TableDisplayWidget extends ConsumerWidget {
  final String tableId;
  const TableDisplayWidget({super.key, required this.tableId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableAsync = ref.watch(getTableByIdProvider(tableId));
    
    return tableAsync.when(
      data: (table) => Text(
        'Table: ${table?.tableNumber ?? tableId}',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      loading: () => Text('Table: $tableId'),
      error: (_, __) => Text('Table: $tableId'),
    );
  }
}

class AdminBillsView extends HookConsumerWidget {
  const AdminBillsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(ordersProvider);
    
    // ALL ANIMATION CONTROLLERS IN BUILD METHOD
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    
    final floatingController = useAnimationController(
      duration: const Duration(milliseconds: 4000),
    );

    final appBarController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    final iconController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    final headerController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    final emptyController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    // ALL ANIMATIONS IN BUILD METHOD
    final floatingAnimation = useAnimation(
      Tween<double>(begin: -6.0, end: 6.0).animate(
        CurvedAnimation(parent: floatingController, curve: Curves.easeInOut),
      ),
    );

    final appBarAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: appBarController, curve: Curves.easeOut),
      ),
    );

    final rotationAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: iconController, curve: Curves.elasticOut),
      ),
    );

    final headerAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: headerController, curve: Curves.easeOutBack),
      ),
    );

    final emptyAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: emptyController, curve: Curves.easeOutBack),
      ),
    );

    useEffect(() {
      animationController.forward();
      floatingController.repeat(reverse: true);
      appBarController.forward();
      iconController.forward();
      
      Future.delayed(const Duration(milliseconds: 300), () {
        headerController.forward();
      });
      
      emptyController.forward();
      
      return null;
    }, []);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF9068BE),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
               _buildEnhancedAppBar(context, appBarAnimation, rotationAnimation),
              Expanded(
                child: Transform.translate(
                  offset: Offset(0, floatingAnimation),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(parent: animationController, curve: Curves.easeOut),
                              ),
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                                  CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
                                ),
                      child: _buildBillsContent(
                        context, 
                        ref, 
                        orderAsync, 
                        headerAnimation, 
                        emptyAnimation,
                      ),
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

  Widget _buildEnhancedAppBar(
    BuildContext context, 
    double appBarAnimation, 
    double rotationAnimation,
  ) {
    return Transform.translate(
      offset: Offset(0, -50 * (1 - appBarAnimation)),
      child: Opacity(
        opacity: appBarAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () => context.goNamed(AppRouteNames.adminPanel),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacityFactor(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacityFactor(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacityFactor(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              
              // Title
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'ACCOUNTS DASHBOARD',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacityFactor(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillsContent(
    BuildContext context, 
    WidgetRef ref, 
    AsyncValue orderAsync,
    double headerAnimation,
    double emptyAnimation,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacityFactor(0.15),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: orderAsync.when(
          data: (orders) {
            final billsInProgress = orders.where(
              (order) => order.status == OrderStatus.preparing.name || 
                         order.status == OrderStatus.served.name
            ).toList();
            
            final billsPaid = orders.where(
              (order) => order.status == OrderStatus.paid.name
            ).toList();
            
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Bills in Progress Section
                  _buildSectionHeader(
                    'Bills in Progress', 
                    billsInProgress.length, 
                    Colors.orange, 
                    Icons.timelapse_rounded,
                    headerAnimation,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 1,
                    child: billsInProgress.isEmpty
                        ? _buildEmptyState('No bills in progress', Colors.orange, emptyAnimation)
                        : _buildAnimatedBillsList(
                            billsInProgress, 
                            Colors.orange, 
                            ref, 
                            false,
                          ),
                  ),
                  
                  const SizedBox(height: 20),
                  _buildDivider(),
                  const SizedBox(height: 20),
                  
                  // Bills Paid Section
                  _buildSectionHeader(
                    'Bills Paid', 
                    billsPaid.length, 
                    Colors.green, 
                    Icons.check_circle_rounded,
                    headerAnimation,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 1,
                    child: billsPaid.isEmpty
                        ? _buildEmptyState('No paid bills', Colors.green, emptyAnimation)
                        : _buildAnimatedBillsList(
                            billsPaid, 
                            Colors.green, 
                            ref, 
                            true,
                          ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading bills...',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ],
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withOpacityFactor(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading bills',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.withOpacityFactor(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  style: TextStyle(
                    color: Colors.red.withOpacityFactor(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, 
    int count, 
    Color color, 
    IconData icon,
    double headerAnimation,
  ) {
    return Transform.scale(
      scale: headerAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacityFactor(0.1), color.withOpacityFactor(0.2)],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacityFactor(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacityFactor(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '$count ${count == 1 ? 'bill' : 'bills'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: color.withOpacityFactor(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, Color color, double emptyAnimation) {
    return Transform.scale(
      scale: emptyAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacityFactor(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 50,
                color: color.withOpacityFactor(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: color.withOpacityFactor(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.withOpacityFactor(0.3),
            Colors.grey.withOpacityFactor(0.1),
            Colors.grey.withOpacityFactor(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildAnimatedBillsList(List orders, Color color, WidgetRef ref, bool isPaidSection) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final totalAmount = order.dishes.fold(0.0, (total, dish) => total + dish.price);
        
        return AnimatedBillCard(
          order: order,
          totalAmount: totalAmount,
          color: color,
          ref: ref,
          isPaidSection: isPaidSection,
          index: index,
        );
      },
    );
  }
}

// Separate HookWidget for individual bill cards
class AnimatedBillCard extends HookWidget {
  final Order order;
  final double totalAmount;
  final Color color;
  final WidgetRef ref;
  final bool isPaidSection;
  final int index;

  const AnimatedBillCard({
    super.key,
    required this.order,
    required this.totalAmount,
    required this.color,
    required this.ref,
    required this.isPaidSection,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final cardController = useAnimationController(
      duration: Duration(milliseconds: 600 + (index * 150)),
    );

    final buttonController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );


    useEffect(() {
      Future.delayed(Duration(milliseconds: 400 + (index * 100)), () {
        cardController.forward();
      });
      return null;
    }, []);

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
                  CurvedAnimation(parent: cardController, curve: Curves.easeOut),
                ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(parent: cardController, curve: Curves.easeOutBack),
                ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: isPaidSection
                ? LinearGradient(
                    colors: [Colors.green.shade50, Colors.green.shade100],
                  )
                : LinearGradient(
                    colors: [color.withOpacityFactor(0.05), color.withOpacityFactor(0.15)],
                  ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPaidSection ? Colors.green.shade200 : color.withOpacityFactor(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isPaidSection 
                    ? Colors.green.withOpacityFactor(0.1)
                    : color.withOpacityFactor(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status Avatar
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPaidSection
                        ? Colors.green
                        : (order.status == OrderStatus.preparing.name ? Colors.orange : Colors.green),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isPaidSection 
                            ? Colors.green.withOpacityFactor(0.4)
                            : color.withOpacityFactor(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isPaidSection
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                      : Text(
                          order.status == OrderStatus.preparing.name ? 'P' : 'S',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                
                const SizedBox(width: 16),
                
                // Order Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TableDisplayWidget(tableId: order.tableId),
                      const SizedBox(height: 4),
                      Text(
                        'Order ID: ${order.orderId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Status: ${order.status.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isPaidSection ? Colors.green.shade700 : color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Items: ${order.dishes.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Amount and Action
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '€${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isPaidSection ? Colors.green.shade700 : color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isPaidSection)
                      GestureDetector(
                        onTapDown: (_) => buttonController.forward(),
                        onTapUp: (_) => buttonController.reverse(),
                        onTapCancel: () => buttonController.reverse(),
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
                                    Expanded(child: Text('Order ${order.orderId} marked as paid!')),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.error, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text('Error: $e')),
                                  ],
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: AnimatedBuilder(
                          animation: buttonController,
                          builder: (context, child) {
                            final scale = 1.0 - (buttonController.value * 0.1);
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green.shade400, Colors.green.shade600],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacityFactor(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Mark Paid',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
