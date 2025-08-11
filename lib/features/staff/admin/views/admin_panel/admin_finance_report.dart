import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/staff/admin/provider/admin_provider.dart';

class AdminFinanceReport extends ConsumerWidget {
  const AdminFinanceReport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalTipsAsyncValue = ref.watch(getTotalTipsStreamProvider);
    final totalFoodSaleAsyncValue = ref.watch(getTotalFoodSaleStreamProvider);
    final revenueAsyncValue = ref.watch(getRevenueStreamProvider);
    final taxAsyncValue = ref.watch(getTaxStreamProvider);
    final inventoryExpenditureAsyncValue = ref.watch(getInventoryExpenditureStreamProvider);
    final expenditureAsyncValue = ref.watch(getExpenditureStreamProvider);
    final netProfitAsyncValue = ref.watch(getNetProfitStreamProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            context.goNamed(
              AppRouteNames.adminPanel
            );
          }, 
          icon: Icon(Icons.arrow_back_ios_new_rounded)
        ),
        title: const Text('Finance Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFinanceTile(
              title: 'Total Tips',
              asyncValue: totalTipsAsyncValue,
            ),
            _buildFinanceTile(
              title: 'Total Food Sale',
              asyncValue: totalFoodSaleAsyncValue,
            ),
            _buildFinanceTile(
              title: 'Revenue',
              asyncValue: revenueAsyncValue,
            ),
            _buildFinanceTile(
              title: 'Tax (15%)',
              asyncValue: taxAsyncValue,
            ),
            _buildFinanceTile(
              title: 'Inventory Expenditure',
              asyncValue: inventoryExpenditureAsyncValue,
            ),
            _buildFinanceTile(
              title: 'Total Expenditure',
              asyncValue: expenditureAsyncValue,
            ),
            _buildFinanceTile(
              title: 'Net Profit',
              asyncValue: netProfitAsyncValue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceTile({
    required String title,
    required AsyncValue<double> asyncValue,
  }) {
    return      ListTile(
        title: Text(title),
        trailing: asyncValue.when(
          data: (value) => Text('€ ${value.toStringAsFixed(2)}'),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        ),
      );
  }
}