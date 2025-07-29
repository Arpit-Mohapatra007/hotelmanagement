import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/models/dish.dart';
import 'package:hotelmanagement/features/dish/dish_repository.dart';

final dishRepositoryProvider = Provider((ref) => DishRepository());

final dishesProvider = StreamProvider((ref) {
  final repository = ref.watch(dishRepositoryProvider);
  return repository.getAllDishes();
});

final availableDishesProvider = StreamProvider((ref) {
  final repository = ref.watch(dishRepositoryProvider);
  return repository.getAvailableDishes();
});

final dishSearchQueryProvider = StateProvider<String>((ref) => '');
final searchedDishesProvider = FutureProvider.family<List<Dish>, String>((ref, query) async {
  final repository = ref.watch(dishRepositoryProvider);
  if (query.isEmpty) {
    // Return all available dishes if search query is empty
    return repository.getAvailableDishes().first; // .first to convert Stream to Future
  }
  return repository.searchDishesByName(query);
});

final dishByIdProvider = FutureProvider.family<Dish?, String>((ref, dishId) async {
  final repository = ref.watch(dishRepositoryProvider);
  return repository.getDishById(dishId);
});

final dishByCategoryProvider = FutureProvider.family<List<Dish>, String>((ref, category) async {
  final repository = ref.watch(dishRepositoryProvider);
  return repository.searchDishesByCategory(category);
});

final dishAddProvider = FutureProvider.family<void, Dish>((ref, dish) async {
  final repository = ref.watch(dishRepositoryProvider);
  await repository.addDish(dish);
});

final dishRemoveProvider = FutureProvider.family<void, String>((ref, dishId) async {
  final repository = ref.watch(dishRepositoryProvider);
  await repository.removeDish(dishId);
});

final dishUpdateProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, data) async {
  final repository = ref.watch(dishRepositoryProvider);
  final dishId = data['dishId'] as String;
  final updatedDish = data['updatedDish'] as Dish;
  await repository.updateDish(dishId, updatedDish);
});

final dishMarkUnavailableProvider = FutureProvider.family<void, String>((ref, dishId) async {
  final repository = ref.watch(dishRepositoryProvider);
  await repository.markDishUnavailable(dishId);
});

final dishMarkAvailableProvider = FutureProvider.family<void, String>((ref, dishId) async {
  final repository = ref.watch(dishRepositoryProvider);
  await repository.markDishAvailable(dishId);
});