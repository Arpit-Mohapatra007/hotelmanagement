import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:hotelmanagement/core/constants/table_status.dart';
import 'package:hotelmanagement/features/dish/dish_provider.dart';
import 'package:hotelmanagement/features/customer/providers/current_order_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/staff/admin/provider/admin_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';
import 'dart:async';

class CustomerDashboard extends HookConsumerWidget {
  final String tableNumber;
  const CustomerDashboard({required this.tableNumber, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(updateTableStatusProvider((tableNumber: tableNumber, newStatus: TableStatus.occupied.name)));

    final searchController = useTextEditingController();
    final searchQuery = ref.watch(dishSearchQueryProvider);
    final dishesAsync = ref.watch(combinedSearchProvider(searchQuery));
    final currentOrderDishes = ref.watch(currentOrderDishesProvider);
    final currentOrderTotal = ref.watch(currentOrderTotalProvider);
    final heroDashboardContent = ref.watch(getHeroImageUrlsProvider);

    final pageController = usePageController();
    final currentPage = useState(0);
    final timer = useRef<Timer?>(null);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    useEffect(() {
      timer.value = Timer.periodic(const Duration(seconds: 3), (Timer t) {
        heroDashboardContent.whenData((images) {
          final imagesList = <String>[];
          for (var entry in images.entries) {
            if ((entry.value).isNotEmpty) imagesList.add(entry.value);
          }
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
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF6B73FF)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildEnhancedAppBar(context, currentOrderDishes, currentOrderTotal),
                Expanded(
                  child: FadeTransition(
                    opacity: Tween(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(parent: animationController, curve: Curves.easeOut)),
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                          CurvedAnimation(parent: animationController, curve: Curves.elasticOut)),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 10),
                              _buildEnhancedOrderSummary(currentOrderDishes, currentOrderTotal),
                              const SizedBox(height: 6),
                              _buildEnhancedSearchBar(searchController, ref),
                              const SizedBox(height: 6),
                              _buildEnhancedHeroSlideshow(
                                heroDashboardContent, pageController, currentPage, context),
                              const SizedBox(height: 8),
                              _buildEnhancedMenuSection(
                                dishesAsync, searchQuery, ref, context),
                              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar(BuildContext context, List currentOrderDishes, double currentOrderTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 700),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, animation, child) => Transform.scale(
              scale: animation,
              child: Hero(
                tag: 'back_button_dashboard',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => context.goNamed(AppRouteNames.tableLogin),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1.1,
                        ),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Table $tableNumber',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildActionButton(
            icon: Icons.fastfood_rounded,
            onTap: () => context.goNamed(AppRouteNames.orderStatus, pathParameters: {'tableNumber': tableNumber}),
            delay: 100,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.shopping_cart_rounded,
            onTap: () => context.goNamed(AppRouteNames.customerCart, pathParameters: {'tableNumber': tableNumber}),
            badge: currentOrderDishes.isNotEmpty ? currentOrderDishes.length : null,
            delay: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    int? badge,
    int delay = 0,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animation, child) => Transform.scale(
        scale: animation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.18),
                  width: 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  if (badge != null)
                    Positioned(
                      right: -4, top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade600,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$badge',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedOrderSummary(List currentOrderDishes, double currentOrderTotal) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long, color: Colors.blue.shade400, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Order: ${currentOrderDishes.length}  •  €${currentOrderTotal.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (currentOrderDishes.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSearchBar(TextEditingController controller, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search dish...',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.blue.shade400, size: 18),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                ),
                onSubmitted: (value) => ref.read(dishSearchQueryProvider.notifier).state = value.trim(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded, size: 18),
              color: Colors.blue.shade400,
              onPressed: () {
                final searchTerm = controller.text.trim();
                ref.read(dishSearchQueryProvider.notifier).state = searchTerm;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedHeroSlideshow(
    AsyncValue heroDashboardContent,
    PageController pageController,
    ValueNotifier currentPage,
    BuildContext context,
  ) {
    final double height = MediaQuery.of(context).size.height * 0.3;;

    return Container(
      margin: const EdgeInsets.all(8),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: heroDashboardContent.when(
        data: (images) {
          final imagesList = <String>[];
          for (var entry in images.entries) {
            if (entry.value is String && (entry.value as String).isNotEmpty) {
              imagesList.add(entry.value as String);
            }
          }
          if (imagesList.isEmpty) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.grey.shade200,
              ),
              child: const Center(child: Icon(Icons.image, size: 32, color: Colors.grey)),
            );
          }
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: PageView.builder(
                  controller: pageController,
                  itemCount: imagesList.length,
                  onPageChanged: (i) => currentPage.value = i,
                  itemBuilder: (context, index) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(imagesList[index]), fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              if (imagesList.length > 1)
                Positioned(
                  bottom: 8, left: 0, right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(imagesList.length, (ind) {
                      final isActive = currentPage.value == ind;
                      return AnimatedContainer(
                        width: isActive ? 14 : 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white70,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          );
        },
        loading: () => Center(
          child: SizedBox(
            height: height,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
        error: (error, stack) => SizedBox(
          height: height,
          child: Center(child: Icon(Icons.error_outline, color: Colors.red.shade400, size: 32)),
        ),
      ),
    );
  }

  Widget _buildEnhancedMenuSection(
    AsyncValue dishesAsync, String searchQuery, WidgetRef ref, BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 10, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.restaurant_menu_rounded, color: Colors.orange.shade400, size: 20),
              const SizedBox(width: 8),
              const Text('Menu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
              if (searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    '🔍 "$searchQuery"',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
        dishesAsync.when(
          data: (dishes) {
            if (dishes.isEmpty && searchQuery.isNotEmpty) {
              return _buildEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No dishes found',
                  subtitle: 'Try searching under a different word',
                  color: Colors.orange,
              );
            } else if (dishes.isEmpty) {
              return _buildEmptyState(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'No dishes available',
                  subtitle: 'Please check back later',
                  color: Colors.grey,
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 24),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dishes.length,
              itemBuilder: (context, index) {
                return _buildEnhancedDishCard(dishes[index], index, ref, context);
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 32),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.blue),
              ),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Icon(Icons.error_outline, size: 28, color: Colors.red.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedDishCard(dynamic dish, int index, WidgetRef ref, BuildContext context) {
    final dishCount = ref.watch(dishCountInOrderProvider(dish));
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade200,
              image: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(dish.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            ),
            child: (dish.imageUrl == null || dish.imageUrl!.isEmpty)
                ? Icon(Icons.restaurant_menu_rounded, color: Colors.grey.shade400, size: 22)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF222A3A)),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  dish.description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      '€${dish.price.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    if (dishCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$dishCount in cart',
                          style: TextStyle(color: Colors.blue.shade800, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.add_shopping_cart_rounded, color: dish.isAvailable ? Colors.green : Colors.grey, size: 18),
                tooltip: dish.isAvailable ? 'Add' : 'Unavailable',
                onPressed: dish.isAvailable
                  ? () {
                      ref.read(currentOrderProvider.notifier).addDish(dish);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${dish.name} added to order!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
              ),
              if (dishCount > 0)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red, size: 18),
                  tooltip: 'Remove',
                  onPressed: () {
                    ref.read(currentOrderProvider.notifier).removeDish(dish);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${dish.name} removed from order!'),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Center(
      child: Column(
        children: [
          Icon(icon, size: 34, color: color.withOpacity(0.6)),
          const SizedBox(height: 14),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color.withOpacity(0.7))),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
