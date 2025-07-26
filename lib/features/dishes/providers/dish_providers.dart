import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmanagement/core/models/dish.dart';
import 'package:hotelmanagement/core/providers/firebase_providers.dart';
import 'package:hotelmanagement/features/dishes/repositories/dish_repository.dart';

final dishRepositoryProvider = Provider<DishRepository>(
  (ref) => DishRepository(
    ref.watch(firestoreProvider)
  ),
);

final dishesProvider = StreamProvider<List<Dish>>((ref) {
  final repository = ref.watch(dishRepositoryProvider);
  return repository.getDishes();
});

final searchDishesProvider = FutureProvider.family<List<Dish>, String>((ref, query) {
  final repository = ref.watch(dishRepositoryProvider);
  return repository.searchDishes(query);
});

final dishSearchQueryProvider = StateProvider<String>((ref) => '');

final dishByIdProvider = FutureProvider.family<Dish?, String>((ref, id) {
  final repository = ref.watch(dishRepositoryProvider);
  return repository.getDishById(id);
});

final dishesByCategoryProvider = StreamProvider.family<List<Dish>, String>((ref, category) {
  final repository = ref.watch(dishRepositoryProvider);
  return repository.getDishesByCategory(category);
});

final updateDishAvailabilityProvider = FutureProvider.family<void, ({String id, bool isAvailable})>((ref, args) {
  final repository = ref.watch(dishRepositoryProvider);
  return repository.updateDishAvailability(args.id, args.isAvailable);
});

final addReviewProvider = FutureProvider.family<void, ({String id, String review})>((ref, args) {
  final repository = ref.watch(dishRepositoryProvider);
  return repository.addReview(args.id, args.review);
});

final addDishProvider = FutureProvider.family<void, Dish>((ref, dish) {
  final repository = ref.watch(dishRepositoryProvider);
  return repository.addDish(dish);
});

final updateDishProvider = FutureProvider.family<void, Dish>((ref, dish) {
  final repository = ref.watch(dishRepositoryProvider);
  return repository.updateDish(dish);
});

final deleteDishProvider = FutureProvider.family<void, String>((ref, id) {
  final repository = ref.watch(dishRepositoryProvider);
  return repository.deleteDish(id);
});
