import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotelmanagement/core/models/dish.dart';

class DishRepository {
  final FirebaseFirestore firestore;

  DishRepository(this.firestore);

  Stream<List<Dish>> getDishes() {
    return firestore.collection('dishes').snapshots().map(
      (snapshot) => snapshot.docs
        .map((doc) => Dish.fromJson(doc.data()..['id'] = doc.id)) 
        .toList(),
    );
  }

  Future<void> addDish(Dish dish) async {
    await firestore.collection('dishes').add(dish.toJson());
  }

  Future<void> updateDish(Dish dish) async {
    await firestore.collection('dishes').doc(dish.id).update(dish.toJson());
  }

  Future<void> deleteDish(String id) async {
    await firestore.collection('dishes').doc(id).delete();
  }

  Future<Dish?> getDishById(String id) async {
  final doc = await firestore.collection('dishes').doc(id).get();
  if (doc.exists) {
    return Dish.fromJson(doc.data()!..['id'] = doc.id);
  }
    return null;
  }

  Stream<List<Dish>> getDishesByCategory(String category) { 
    return firestore.collection('dishes').where('category', isEqualTo: category).snapshots().map(
      (snapshot) => snapshot.docs
        .map((doc) => Dish.fromJson(doc.data()..['id'] = doc.id))
        .toList(),
    );
   }

  Future<List<Dish>> searchDishes(String query) async {
  final snapshot = await firestore.collection('dishes')
    .where('name', isGreaterThanOrEqualTo: query)
    .where('name', isLessThanOrEqualTo: '$query\uf8ff')
    .get();
  return snapshot.docs.map((doc) => Dish.fromJson(doc.data()..['id'] = doc.id)).toList();
}



  Future<void> updateDishAvailability(String id, bool isAvailable) { 
    return firestore.collection('dishes').doc(id).update({'isAvailable': isAvailable});
   }


  Future<void> addReview(String id, String review) { 
    return firestore.collection('dishes').doc(id).update({
      'reviews': FieldValue.arrayUnion([review])
    });
   }


}