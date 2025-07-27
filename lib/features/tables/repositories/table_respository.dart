import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotelmanagement/core/models/table.dart';
class TableRepository {
  final FirebaseFirestore firestore;

  TableRepository(this.firestore);

  Stream<List<Table>> getTables() {
    return firestore.collection('tables').snapshots().map(
      (snapshot) => snapshot.docs
        .map((doc) => Table.fromJson(doc.data()..['id'] = doc.id)) 
        .toList(),
    );
  }

  Future<void> addTable(Table table) async {
    await firestore.collection('tables').add(table.toJson());
  }

  Future<void> updateTableStatus(String tableId, String status) async {
    await firestore.collection('tables').doc(tableId).update({'status': status});
  }

  Future<void> deleteTable(String tableId) async {
    await firestore.collection('tables').doc(tableId).delete();
  }

  Future<void> updateCurrentBill(String tableId, double currentBill) async {
    await firestore.collection('tables').doc(tableId).update({'currentBill': currentBill});
  }

  Future<void> clearSession(String tableId) async {
    await firestore.collection('tables').doc(tableId).update({'sessionInfo': ''});
  }

  Future<void> addSessionInfo(String tableId, String sessionInfo) async {
    await firestore.collection('tables').doc(tableId).update({'sessionInfo': sessionInfo});
  }
}