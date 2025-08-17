// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/constants/order_status.dart';
import 'package:hotelmanagement/core/constants/table_status.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';
import 'package:hotelmanagement/core/models/dish.dart';

class BillView extends HookConsumerWidget {
  final String tableNumber;

  const BillView({super.key, required this.tableNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipController = useTextEditingController();
    final tableAsync = ref.watch(getTableByNumberProvider(tableNumber));
    
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    
    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    const double taxRate = 0.15; // 15%

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
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Hero(
                      tag: 'back_button_bill',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: () => context.goNamed(
                            AppRouteNames.orderStatus,
                            pathParameters: {'tableNumber': tableNumber},
                          ),
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
                    Expanded(
                      child: Text(
                        'Bill - Table $tableNumber',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 49),
                  ],
                ),
              ),

              Expanded(
                child: tableAsync.when(
                  data: (table) {
                    if (table == null) {
                      return _buildErrorState('Table not found');
                    }

                    final billableOrders = table.orders.where(
                      (o) => o.status == OrderStatus.preparing.name || 
                             o.status == OrderStatus.ready.name
                    );

                    if (billableOrders.isEmpty) {
                      return _buildEmptyState();
                    }

                    final allDishes = billableOrders.expand((order) => order.dishes).toList();
                    final Map<String, ({Dish dish, int quantity})> items = {};
                    double subtotal = 0;

                    for (var dish in allDishes) {
                      subtotal += dish.price;
                      items.update(
                        dish.name,
                        (value) => (dish: value.dish, quantity: value.quantity + 1),
                        ifAbsent: () => (dish: dish, quantity: 1),
                      );
                    }

                    final taxAmount = subtotal * taxRate;
                    final tipAmount = double.tryParse(tipController.text) ?? 0.0;
                    final grandTotal = subtotal + taxAmount + tipAmount;

                    return FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(parent: animationController, curve: Curves.easeOut),
                              ),
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                                    CurvedAnimation(parent: animationController, curve: Curves.elasticOut),
                                  ),
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Bill Header
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade50,
                                      Colors.purple.shade50,
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Hero(
                                      tag: 'bill_icon',
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Icon(
                                          Icons.receipt_long_rounded,
                                          color: Colors.blue.shade700,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Your Bill',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2D3748),
                                            ),
                                          ),
                                          Text(
                                            'Review your order details',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Items List
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: items.isEmpty
                                      ? const Center(child: Text('No items to bill'))
                                      : ListView.builder(
                                          itemCount: items.length,
                                          itemBuilder: (context, index) {
                                            final item = items.values.elementAt(index);
                                            return _buildItemCard(item, index);
                                          },
                                        ),
                                ),
                              ),

                              // Bill Summary
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    _buildBillRow('Subtotal', subtotal),
                                    const SizedBox(height: 8),
                                    _buildBillRow('Tax (15%)', taxAmount),
                                    if (tipAmount > 0) ...[
                                      const SizedBox(height: 8),
                                      _buildBillRow('Tip', tipAmount),
                                    ],
                                    const Divider(thickness: 2, height: 24),
                                    _buildBillRow('Grand Total', grandTotal, isBold: true),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Tip Input
                                    _buildTipInput(tipController),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Pay Button
                                    _buildPayButton(context, ref, tipAmount, tableNumber),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => _buildLoadingState(),
                  error: (error, stack) => _buildErrorState('Error loading bill: $error'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(({Dish dish, int quantity}) item, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.dish.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${item.quantity} × €${item.dish.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '€${(item.dish.price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? const Color(0xFF2D3748) : Colors.grey.shade700,
          ),
        ),
        Text(
          '€${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? const Color(0xFF2D3748) : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTipInput(TextEditingController tipController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: tipController,
        decoration: InputDecoration(
          labelText: 'Add Tip (€) - Optional',
          hintText: '0.00',
          prefixIcon: Icon(Icons.euro_rounded, color: Colors.green.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        onChanged: (value) {
          // Trigger rebuild to update grand total
          (tipController.text.isNotEmpty)
              ? tipController.text = value
              : tipController.text = '0.00';
        },
      ),
    );
  }

  Widget _buildPayButton(BuildContext context, WidgetRef ref, double tipAmount, String tableNumber) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () async {
            try {
              if (tipAmount > 0) {
                await ref.read(addTipToTableProvider((
                  tableNumber: tableNumber,
                  tipAmount: tipAmount
                )).future);
              }

              ref.read(updateTableStatusProvider((
                tableNumber: tableNumber,
                newStatus: TableStatus.available.name
              )).future);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(tipAmount > 0
                          ? 'Payment processed! Thank you for the €${tipAmount.toStringAsFixed(2)} tip!'
                          : 'Payment processed!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );

              context.goNamed(AppRouteNames.tableLogin);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error processing payment: $e'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.payment_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Pay Now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Loading your bill...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Items to Bill',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'No billable items found for this table',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
