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

final updateOrderInTableProvider = FutureProvider.autoDispose
    .family<void, ({String tableNumber, Order order})>((ref, args) {
  final repository = ref.watch(tableRepositoryProvider);
  return repository.updateOrderInTable(args.tableNumber, args.order);
});


final addOrderToTableProvider = FutureProvider.autoDispose.family<void, ({String tableNumber, Order order})>((ref, args) {
  final repository = ref.watch(tableRepositoryProvider);
  // No more manual casting from Map, directly use the typed arguments
  return repository.addOrderToTable(args.tableNumber, args.order);
});


final getOrdersForTableProvider = StreamProvider.autoDispose.family<List<Order>, String>((ref, tableNumber) {
  final repository = ref.watch(tableRepositoryProvider);
  return repository.getOrdersForTable(tableNumber);
});

final checkTableExistsProvider = FutureProvider.autoDispose.family<bool, String>((ref, tableNumber) {
  final repository = ref.watch(tableRepositoryProvider);
  return repository.checkTableExists(tableNumber);
});
