import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmanagement/core/models/dish.dart';
import 'package:hotelmanagement/core/models/order.dart';

/// Represents the state of the current order (cart) for a customer.
class CurrentOrderState {
  final List<Dish> dishes;
  final double totalAmount;
  final String? specialInstructions;

  CurrentOrderState({
    this.dishes = const [],
    this.totalAmount = 0.0,
    this.specialInstructions,
  });

  // Helper to calculate total amount based on dishes
  double _calculateTotal(List<Dish> currentDishes) {
    return currentDishes.fold(0.0, (sum, dish) => sum + dish.price);
  }

  // CopyWith for immutability
  CurrentOrderState copyWith({
    List<Dish>? dishes,
    double? totalAmount,
    String? specialInstructions,
  }) {
    final updatedDishes = dishes ?? this.dishes;
    return CurrentOrderState(
      dishes: updatedDishes,
      totalAmount: _calculateTotal(updatedDishes), // Always recalculate total
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

/// Manages the state of the customer's current order (cart).
class CurrentOrderNotifier extends Notifier<CurrentOrderState> {
  @override
  CurrentOrderState build() {
    return CurrentOrderState();
  }

  void addDish(Dish dish) {
    state = state.copyWith(dishes: [...state.dishes, dish]);
  }

  void removeDish(Dish dish) {
    final List<Dish> updatedDishes = List.from(state.dishes);
    final index = updatedDishes.indexWhere((d) => d.id == dish.id);
    if (index != -1) {
      updatedDishes.removeAt(index);
      state = state.copyWith(dishes: updatedDishes);
    }
  }

  void clearOrder() {
    state = CurrentOrderState();
  }

  void updateSpecialInstructions(String instructions) {
    state = state.copyWith(specialInstructions: instructions);
  }

  void loadOrder(Order order) {
    state = state.copyWith(
      dishes: order.dishes,
      specialInstructions: order.specialInstructions,
    );
  }
  
}

final currentOrderProvider = NotifierProvider<CurrentOrderNotifier, CurrentOrderState>(() {
  return CurrentOrderNotifier();
});

// A provider to easily access the list of dishes in the current order
final currentOrderDishesProvider = Provider<List<Dish>>((ref) {
  return ref.watch(currentOrderProvider).dishes;
});

// A provider to easily access the total amount of the current order
final currentOrderTotalProvider = Provider<double>((ref) {
  return ref.watch(currentOrderProvider).totalAmount;
});

// You might also want a provider for the count of a specific dish in the cart
final dishCountInOrderProvider = Provider.family<int, Dish>((ref, dish) {
  final currentOrder = ref.watch(currentOrderProvider);
  return currentOrder.dishes.where((d) => d.id == dish.id).length;
});