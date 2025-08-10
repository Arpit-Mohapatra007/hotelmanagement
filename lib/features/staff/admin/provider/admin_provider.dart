// admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

// Main financial metrics
final totalIncomeProvider = StreamProvider.autoDispose<double>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getTotalIncomeStream();
});

final totalExpenditureProvider = StreamProvider.autoDispose<double>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getTotalExpenditureStream();
});

final netProfitProvider = StreamProvider.autoDispose<double>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getNetProfitStream();
});

final totalTipsProvider = StreamProvider.autoDispose<double>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getTotalTipsStream();
});

final foodSalesProvider = StreamProvider.autoDispose<double>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getFoodSalesStream();
});

final inventoryExpensesProvider = StreamProvider.autoDispose<double>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getInventoryExpensesStream();
});

// Fixed Tax provider (18% GST on food sales)
final taxProvider = StreamProvider.autoDispose<double>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getFoodSalesStream().map((foodSales) => foodSales * 0.18);
});

// Fixed Revenue breakdown provider
final revenueBreakdownProvider = StreamProvider.autoDispose<Map<String, double>>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  
  // Use Rx.combineLatest2 to properly combine streams
  return Rx.combineLatest2(
    repository.getFoodSalesStream(),
    repository.getTotalTipsStream(),
    (double foodSales, double tips) => {
      'Food Sales': foodSales,
      'Tips': tips,
    },
  );
});

// Fixed Expenditure breakdown provider
final expenditureBreakdownProvider = StreamProvider.autoDispose<Map<String, double>>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  
  return repository.getInventoryExpensesStream().map((inventoryExpense) {
    return {
      'Inventory': inventoryExpense,
      'Staff Salaries': 25000.0,
      'Rent': 8000.0,
      'Utilities': 3000.0,
      'Marketing': 2000.0,
      'Maintenance': 1500.0,
    };
  });
});
