import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepository {
  Stream<double> getTotalTipsStream() {
    return FirebaseFirestore.instance
        .collection('tables')
        .snapshots()
        .map((snapshot) {
      double totalTips = 0.0;
      for (var doc in snapshot.docs) {
        if (doc.exists && doc.data().containsKey('totalTips')) {
          totalTips += (doc.data()['totalTips'] as num?)?.toDouble() ?? 0.0;
        }
      }
      return totalTips;
    });
  }

  Stream<double> getTotalFoodSaleStream() {
    return FirebaseFirestore.instance
        .collection('tables')
        .snapshots()
        .map((snapshot) {
          double totalFoodSale = 0.0;
          for (var doc in snapshot.docs){
            if(doc.exists && doc.data().containsKey('orders') && doc.data()['orders'] is List){
              List<dynamic> orders = doc.data()['orders'];
              for(var orderData in orders){
                if(orderData is Map<String, dynamic> && orderData.containsKey('status') && orderData['status'] == 'paid'){
                  totalFoodSale += (orderData['price'] as num?)?.toDouble() ?? 0.0;
                }
              }
            }
          }
          return totalFoodSale;
        });
  }

  Stream<double> getRevenueStream(){
    return getTotalFoodSaleStream().asyncMap((totalFoodSale) async {
      final totalTips = await getTotalTipsStream().first;
      return totalFoodSale + totalTips;
    });
  }

  Stream<double> getTaxStream() {
    return getTotalFoodSaleStream().asyncMap((totalFoodSale) async {
      final totalTips = await getTotalTipsStream().first;
      return 0.15 * (totalFoodSale + totalTips);
    });
  }

  Stream<double> getInventoryExpenditureStream(){
    return FirebaseFirestore.instance
        .collection('inventory')
        .snapshots()
        .map((snapshot) {
          double totalInventoryExpenditure = 0.0;
          for (var doc in snapshot.docs){
            if(doc.exists && doc.data().containsKey('price') && doc.data().containsKey('quantity')){
              totalInventoryExpenditure += (doc.data()['price'] as num?)?.toDouble() ?? 0.0 * (doc.data()['quantity'] as num?)!.toDouble();
            }
          }
          return totalInventoryExpenditure;
        });
  }

  Stream<double> getExpenditureStream(){
    return getInventoryExpenditureStream().asyncMap((totalInventoryExpenditure) async {
      final tax = await getTaxStream().first;
      return totalInventoryExpenditure + tax;
    });
  }

  Stream<double> getNetProfitStream(){
    return getRevenueStream().asyncMap((totalRevenue) async {
      final expenditure = await getExpenditureStream().first;
      return totalRevenue - expenditure;
    });
  }
  
}