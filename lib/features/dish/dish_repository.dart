import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotelmanagement/core/models/dish.dart';

class DishRepository {
  //all dishes
  Stream<List<Dish>> getAllDishes()  {
    return FirebaseFirestore.instance
        .collection('dishes')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Dish.fromJson(doc.data())).toList());
  }
  //get available dishes
  Stream<List<Dish>> getAvailableDishes() {
    return FirebaseFirestore.instance
        .collection('dishes')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Dish.fromJson(doc.data())).toList());
  }
  // search dish with name
  Future<List<Dish>> searchDishesByName(String query) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('dishes')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs.map((doc) => Dish.fromJson(doc.data())).toList();
  }
  // search dish with category
  Future<List<Dish>> searchDishesByCategory(String query) async{
     final snapshot = await FirebaseFirestore.instance
        .collection('dishes')
        .where('category', isGreaterThanOrEqualTo: query)
        .where('category', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs.map((doc) => Dish.fromJson(doc.data())).toList();
  } 
  //get dish by id
  Future<Dish?> getDishById(String dishId) async {
    final doc = await FirebaseFirestore.instance.collection('dishes').doc(dishId).get();
    if (doc.exists) {
      return Dish.fromJson(doc.data()!);
    }
    return null;
  }
  //add a dish
  Future<void> addDish(Dish dish) async {
    await FirebaseFirestore.instance.collection('dishes').doc(dish.id)
        .set(dish.toJson());
  }
  //remove a dish
  Future<void> removeDish(String dishId) async {
    await FirebaseFirestore.instance.collection('dishes').doc(dishId).delete();
  }
  //mark a dish as unavailable
  Future<void> markDishUnavailable(String dishId) async {
    await FirebaseFirestore.instance.collection('dishes').doc(dishId).update({'available': false});
  }
  //mark a dish as available
  Future<void> markDishAvailable(String dishId) async {
    await FirebaseFirestore.instance.collection('dishes').doc(dishId).update({'available': true});
  }
  //update a dish
  Future<void> updateDish(String dishId, Dish updatedDish) async {
    await FirebaseFirestore.instance.collection('dishes').doc(dishId).update(updatedDish.toJson());
  }
}