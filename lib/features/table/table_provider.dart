import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/models/table.dart' as model; 
import 'package:hotelmanagement/features/table/table_repository.dart';
import 'package:hotelmanagement/core/models/order.dart';

final tableRepositoryProvider = Provider<TableRepository>((ref) => TableRepository());

final tablesProvider = StreamProvider.autoDispose((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return repository.getAllTables();
});

final addTableProvider = FutureProvider.autoDispose.family<void, model.Table>((ref, table) {
  final repository = ref.watch(tableRepositoryProvider);
  return repository.addTable(table);
});

final deleteTableProvider = FutureProvider.autoDispose.family<void, String>((ref, tableNumber) {
  final repository = ref.watch(tableRepositoryProvider);
  return repository.deleteTable(tableNumber);
});

final getTableByNumberProvider = FutureProvider.autoDispose.family<model.Table?, String>((ref, tableNumber) {
  final repository = ref.watch(tableRepositoryProvider);
  return repository.getTableByNumber(tableNumber);
});

// MODIFIED: Changed parameter type to accept Order directly
final addOrderToTableProvider = FutureProvider.autoDispose.family<void, Map<String, dynamic>>((ref, params) {
  final repository = ref.watch(tableRepositoryProvider);
  final tableNumber = params['tableNumber'] as String;
  final order = params['order'] as Order; // Now expects an Order object
  return repository.addOrderToTable(tableNumber, order);
});

// MODIFIED: Changed return type to List<Order>
final getOrdersForTableProvider = StreamProvider.autoDispose.family<List<Order>, String>((ref, tableNumber) {
  final repository = ref.watch(tableRepositoryProvider);
  return repository.getOrdersForTable(tableNumber);
});