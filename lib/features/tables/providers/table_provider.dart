import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmanagement/core/models/table.dart';
import 'package:hotelmanagement/core/providers/firebase_providers.dart';
import 'package:hotelmanagement/features/tables/repositories/table_respository.dart';

final tableRepositoryProvider = Provider<TableRepository>(
  (ref) => TableRepository(ref.watch(firestoreProvider)),
);

final allTablesProvider = StreamProvider<List<Table>>((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  return repository.getTables();
});

final addTableProvider = FutureProvider.family<void, Table>((ref, table) async {
  final repository = ref.watch(tableRepositoryProvider);
  await repository.addTable(table);
});

final updateTableStatusProvider = FutureProvider.family<void, ({String tableId, String status})>((ref, args ) async {
  final repository = ref.watch(tableRepositoryProvider);
  await repository.updateTableStatus(args.tableId, args.status); 
});

final deleteTableProvider = FutureProvider.family<void, String>((ref, tableId) async {
  final repository = ref.watch(tableRepositoryProvider);
  await repository.deleteTable(tableId);
});

final updateCurrentBillProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
  final repository = ref.watch(tableRepositoryProvider);
  await repository.updateCurrentBill(params['tableId'], params['currentBill']);
});

final clearSessionProvider = FutureProvider.family<void, String>((ref, tableId) async {
  final repository = ref.watch(tableRepositoryProvider);
  await repository.clearSession(tableId);
});

final addSessionInfoProvider = FutureProvider.family<void, Map<String, String>>((ref, params) async {
  final repository = ref.watch(tableRepositoryProvider);
  await repository.addSessionInfo(params['tableId']!, params['sessionInfo']!);
});