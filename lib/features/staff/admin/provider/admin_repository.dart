// admin_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:rxdart/rxdart.dart';
import 'package:hotelmanagement/core/models/order.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fixed getTotalIncomeStream with proper error handling
  Stream<double> getTotalIncomeStream() {
    return _firestore.collection('tables').snapshots().map((snapshot) {
      double totalIncome = 0.0;
      
      for (var tableDoc in snapshot.docs) {
        try {
          final tableData = tableDoc.data();
          
          // Access orders from each table document
          if (tableData.containsKey('orders') && tableData['orders'] != null) {
            final List ordersData = tableData['orders'] as List;
            
            for (var orderData in ordersData) {
              try {
                final order = Order.fromJson(orderData as Map<String, dynamic>);
                if (order.status == 'paid') {
                  totalIncome += order.price;
                }
              } catch (e) {
                print('Error parsing order: $e');
              }
            }
          }
          
          // Add tips to total income
          final tableTips = (tableData['totalTip'] as num?)?.toDouble() ?? 0.0;
          totalIncome += tableTips;
        } catch (e) {
          print('Error processing table ${tableDoc.id}: $e');
        }
      }
      return totalIncome;
    }).handleError((error) {
      print('Error in getTotalIncomeStream: $error');
      return 0.0;
    });
  }

  // Fixed getTotalExpenditureStream
  Stream<double> getTotalExpenditureStream() {
    return _firestore.collection('inventory').snapshots().map((snapshot) {
      double totalExpenditure = 0.0;
      
      // Calculate inventory costs
      for (var itemDoc in snapshot.docs) {
        try {
          final itemData = itemDoc.data();
          final price = (itemData['price'] as num?)?.toDouble() ?? 0.0;
          final quantity = (itemData['quantity'] as num?)?.toDouble() ?? 0.0;
          totalExpenditure += price * quantity;
        } catch (e) {
          print('Error parsing inventory item ${itemDoc.id}: $e');
        }
      }
      
      // Add fixed costs
      totalExpenditure += 25000.0; // Staff salaries
      totalExpenditure += 8000.0;  // Rent
      totalExpenditure += 3000.0;  // Utilities
      totalExpenditure += 2000.0;  // Marketing
      totalExpenditure += 1500.0;  // Maintenance
      
      return totalExpenditure;
    }).handleError((error) {
      print('Error in getTotalExpenditureStream: $error');
      return 0.0;
    });
  }

  // Fixed getNetProfitStream using combineLatest
  Stream<double> getNetProfitStream() {
    return Rx.combineLatest2(
      getTotalIncomeStream(),
      getTotalExpenditureStream(),
      (double income, double expenditure) => income - expenditure,
    );
  }

  // Fixed getTotalTipsStream
  Stream<double> getTotalTipsStream() {
    return _firestore.collection('tables').snapshots().map((snapshot) {
      double totalTips = 0.0;
      
      for (var tableDoc in snapshot.docs) {
        try {
          final tableData = tableDoc.data();
          // Use correct field name 'totalTip' (not 'totalTips')
          final tableTips = (tableData['totalTip'] as num?)?.toDouble() ?? 0.0;
          totalTips += tableTips;
        } catch (e) {
          print('Error processing tips for table ${tableDoc.id}: $e');
        }
      }
      return totalTips;
    }).handleError((error) {
      print('Error in getTotalTipsStream: $error');
      return 0.0;
    });
  }

  // Fixed getFoodSalesStream - access orders from tables, not separate collection
  Stream<double> getFoodSalesStream() {
    return _firestore.collection('tables').snapshots().map((snapshot) {
      double foodSales = 0.0;
      
      for (var tableDoc in snapshot.docs) {
        try {
          final tableData = tableDoc.data();
          
          if (tableData.containsKey('orders') && tableData['orders'] != null) {
            final List ordersData = tableData['orders'] as List;
            
            for (var orderData in ordersData) {
              try {
                final order = Order.fromJson(orderData as Map<String, dynamic>);
                if (order.status == 'paid') {
                  foodSales += order.price;
                }
              } catch (e) {
                print('Error parsing food order: $e');
              }
            }
          }
        } catch (e) {
          print('Error processing food sales for table ${tableDoc.id}: $e');
        }
      }
      return foodSales;
    }).handleError((error) {
      print('Error in getFoodSalesStream: $error');
      return 0.0;
    });
  }

  // Additional method for inventory expenses
  Stream<double> getInventoryExpensesStream() {
    return _firestore.collection('inventory').snapshots().map((snapshot) {
      double inventoryExpense = 0.0;
      
      for (var itemDoc in snapshot.docs) {
        try {
          final itemData = itemDoc.data();
          final price = (itemData['price'] as num?)?.toDouble() ?? 0.0;
          final quantity = (itemData['quantity'] as num?)?.toDouble() ?? 0.0;
          inventoryExpense += price * quantity;
        } catch (e) {
          print('Error parsing inventory expense: $e');
        }
      }
      return inventoryExpense;
    }).handleError((error) {
      print('Error in getInventoryExpensesStream: $error');
      return 0.0;
    });
  }
}
