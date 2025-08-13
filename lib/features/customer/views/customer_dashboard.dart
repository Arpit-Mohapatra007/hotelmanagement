// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/constants/table_status.dart';
import 'dart:async'; 
import 'package:hotelmanagement/features/dish/dish_provider.dart';
import 'package:hotelmanagement/features/customer/providers/current_order_provider.dart';
import 'package:go_router/go_router.dart'; 
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/staff/admin/provider/admin_provider.dart'; // Add this import
import 'package:hotelmanagement/features/table/table_provider.dart';

class CustomerDashboard extends HookConsumerWidget {
  final String tableNumber;
  const CustomerDashboard({required this.tableNumber, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(updateTableStatusProvider((tableNumber: tableNumber, newStatus: TableStatus.occupied.name)));
    final searchController = useTextEditingController(); 
    final searchQuery = ref.watch(dishSearchQueryProvider);
    
    // Watch searchedDishesProvider directly based on the searchQuery
    final dishesAsync = ref.watch(combinedSearchProvider(searchQuery));
    // Watch the current order dishes and total for displaying in the UI
    final currentOrderDishes = ref.watch(currentOrderDishesProvider);
    final currentOrderTotal = ref.watch(currentOrderTotalProvider);
    
    // **ADD HERO SLIDESHOW FUNCTIONALITY**
    final heroDashboardContent = ref.watch(getHeroImageUrlsProvider);
    final pageController = usePageController();
    final currentPage = useState(0);
    final timer = useRef<Timer?>(null);

    // Auto-scroll effect for slideshow
    useEffect(() {
      timer.value = Timer.periodic(const Duration(seconds: 3), (Timer t) {
        heroDashboardContent.whenData((images) {
          final imagesList = images.values.where((url) => url.isNotEmpty).toList();
          if (imagesList.isNotEmpty && pageController.hasClients) {
            final nextPage = (currentPage.value + 1) % imagesList.length;
            pageController.animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
            currentPage.value = nextPage;
          }
        });
      });

      return () => timer.value?.cancel();
    }, []);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            context.goNamed(AppRouteNames.tableLogin);
          },
        ),
        title: Text('Table $tableNumber'),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: (){
                  context.goNamed(
                    AppRouteNames.orderStatus,
                    pathParameters: {'tableNumber': tableNumber},
                  );
                }, 
                icon: const Icon(Icons.fastfood),
                iconSize: 30.0,
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                iconSize: 30.0,
                onPressed: () {
                  context.goNamed(
                    AppRouteNames.customerCart,
                    pathParameters: {'tableNumber': tableNumber},
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8.0),
          // Display current order summary in AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Items: ${currentOrderDishes.length} | Total: €${currentOrderTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController, 
                    decoration: const InputDecoration(
                      labelText: 'Search your dish',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      // Automatically trigger search on submit (Enter key)
                      ref.read(dishSearchQueryProvider.notifier).state = value.trim();
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    final searchTerm = searchController.text.toLowerCase().trim();
                    ref.read(dishSearchQueryProvider.notifier).state = searchTerm;
                    },
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          
          GestureDetector(
            onTap: () {
              // Add your custom onTap functionality here
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hero Slideshow'),
                  content: Text('Current image: ${currentPage.value + 1}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: heroDashboardContent.when(
              data: (images) {
                final imagesList = images.values.where((url) => url.isNotEmpty).toList();
                
                if (imagesList.isEmpty) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.grey[300],
                    ),
                    margin: const EdgeInsets.all(16.0),
                    child: const Center(child: Text('No hero images available')),
                  );
                }

                return Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  margin: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      // PageView for slideshow
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: imagesList.length,
                          onPageChanged: (index) {
                            currentPage.value = index;
                          },
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(imagesList[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Page indicators
                      if (imagesList.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              imagesList.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                width: 8.0,
                                height: 8.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: currentPage.value == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      // Manual navigation arrows
                      if (imagesList.length > 1) ...[
                        Positioned(
                          left: 8,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                final prevPage = currentPage.value == 0 
                                    ? imagesList.length - 1 
                                    : currentPage.value - 1;
                                pageController.animateToPage(
                                  prevPage,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                final nextPage = (currentPage.value + 1) % imagesList.length;
                                pageController.animateToPage(
                                  nextPage,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
              loading: () => Container(
                height: MediaQuery.of(context).size.height * 0.3,
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.grey[200],
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Container(
                height: MediaQuery.of(context).size.height * 0.3,
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.red[100],
                ),
                child: Center(child: Text('Error loading images: $error')),
              ),
            ),
          ),
          
          const SizedBox(height: 8.0),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: dishesAsync.when(
              data: (dishes) {
                if (dishes.isEmpty && searchQuery.isNotEmpty) {
                  return const Center(child: Text('No dishes found for your search.'));
                } else if (dishes.isEmpty) {
                  return const Center(child: Text('No dishes available.'));
                }
                return ListView.builder(
                  itemCount: dishes.length,
                  itemBuilder: (context, index) {
                    final dish = dishes[index];
                    // Watch the count of this specific dish in the current order
                    final dishCount = ref.watch(dishCountInOrderProvider(dish));
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      elevation: 2.0,
                      child: ListTile(
                        leading: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(dish.imageUrl!),
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.restaurant_menu),
                              ),
                        title: Text(
                          dish.name,
                          style: const TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          dish.description,
                          style: TextStyle(fontSize: 14.0, color: Colors.grey[300]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '€${dish.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8.0),
                            // Display count of dish in order
                            if (dishCount > 0)
                              Text(
                                '$dishCount',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            const SizedBox(width: 4.0),
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              color: Colors.green,
                              onPressed: dish.isAvailable
                                  ? () {
                                      ref.read(currentOrderProvider.notifier).addDish(dish);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${dish.name} added to order!')),
                                      );
                                    }
                                  : null, // Button is disabled if dish is not available
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              color: Colors.red,
                              onPressed: dishCount > 0 // Only enable if dish is in cart
                                  ? () {
                                      ref.read(currentOrderProvider.notifier).removeDish(dish);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${dish.name} removed from order!')),
                                      );
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
