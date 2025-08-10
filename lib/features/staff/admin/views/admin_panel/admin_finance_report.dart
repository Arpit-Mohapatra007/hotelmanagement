// admin_finance_report.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/staff/admin/provider/admin_provider.dart';

class AdminFinanceReport extends ConsumerWidget {
  const AdminFinanceReport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.goNamed(AppRouteNames.adminPanel);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Finance Report'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Financial Metrics
            _buildMainMetrics(ref),
            const SizedBox(height: 24),
            
            // Revenue Breakdown
            _buildRevenueSection(ref),
            const SizedBox(height: 24),
            
            // Expenditure Breakdown
            _buildExpenditureSection(ref),
            const SizedBox(height: 24),
            
            // Charts
            _buildChartsSection(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMetrics(WidgetRef ref) {
    final income = ref.watch(totalIncomeProvider);
    final expenditure = ref.watch(totalExpenditureProvider);
    final profit = ref.watch(netProfitProvider);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Income',
                    income,
                    Colors.green,
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Total Expenditure',
                    expenditure,
                    Colors.red,
                    Icons.trending_down,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Net Profit',
                    profit,
                    profit.valueOrNull != null && profit.valueOrNull! >= 0
                        ? Colors.blue
                        : Colors.red,
                    Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, AsyncValue<double> value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          value.when(
            data: (data) => Text(
              '₹${data.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            loading: () => const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (error, stack) => Text(
              'Error',
              style: TextStyle(color: color, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSection(WidgetRef ref) {
    final foodSales = ref.watch(foodSalesProvider);
    final tax = ref.watch(taxProvider);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildListTile(
              'Food Sales',
              foodSales,
              Icons.restaurant,
              Colors.blue,
            ),
            _buildListTile(
              'Tax (GST 18%)',
              tax,
              Icons.receipt,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenditureSection(WidgetRef ref) {
    final inventoryExpenses = ref.watch(inventoryExpensesProvider);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expenditure Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildListTile(
              'Inventory Expenses',
              inventoryExpenses,
              Icons.inventory,
              Colors.red,
            ),
            _buildStaticListTile('Staff Salaries', 25000.0, Icons.people, Colors.purple),
            _buildStaticListTile('Rent', 8000.0, Icons.home, Colors.brown),
            _buildStaticListTile('Utilities', 3000.0, Icons.electrical_services, Colors.yellow[700]!),
            _buildStaticListTile('Marketing', 2000.0, Icons.campaign, Colors.green),
            _buildStaticListTile('Maintenance', 1500.0, Icons.build, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, AsyncValue<double> value, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: value.when(
        data: (data) => Text(
          '₹${data.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        loading: () => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (error, stack) => const Text(
          'Error',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildStaticListTile(String title, double amount, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: Text(
        '₹${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildChartsSection(WidgetRef ref) {
    final revenueBreakdown = ref.watch(revenueBreakdownProvider);
    final expenditureBreakdown = ref.watch(expenditureBreakdownProvider);

    return Column(
      children: [
        // Revenue Chart
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Revenue Distribution',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: revenueBreakdown.when(
                    data: (data) => _buildPieChart(data, [Colors.blue, Colors.green]),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => const Center(child: Text('Error loading revenue data')),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Expenditure Chart
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expenditure Distribution',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: expenditureBreakdown.when(
                    data: (data) => _buildPieChart(data, [
                      Colors.red,
                      Colors.purple,
                      Colors.brown,
                      Colors.yellow[700]!,
                      Colors.green,
                      Colors.grey,
                    ]),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => const Center(child: Text('Error loading expenditure data')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(Map<String, double> data, List<Color> colors) {
    if (data.isEmpty || data.values.every((value) => value == 0)) {
      return const Center(child: Text('No data available'));
    }

    return PieChart(
      PieChartData(
        sections: data.entries.map((entry) {
          final index = data.keys.toList().indexOf(entry.key);
          return PieChartSectionData(
            value: entry.value,
            title: '${entry.key}\n₹${entry.value.toStringAsFixed(0)}',
            color: colors[index % colors.length],
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 50,
      ),
    );
  }
}
