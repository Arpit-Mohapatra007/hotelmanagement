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
import 'package:hotelmanagement/features/staff/admin/provider/admin_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

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

    // Animation controllers
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    
    

    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    // Auto-scroll effect for slideshow with proper type handling
    useEffect(() {
      timer.value = Timer.periodic(const Duration(seconds: 3), (Timer t) {
        heroDashboardContent.whenData((images) {
          // Fixed type handling to prevent errors
          final imagesList = <String>[];
          for (var entry in images.entries) {
            if ((entry.value).isNotEmpty) {
              imagesList.add(entry.value);
            }
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF6B73FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced Custom AppBar
              _buildEnhancedAppBar(context, currentOrderDishes, currentOrderTotal),
              
              Expanded(
                child: FadeTransition(
                  opacity:
                        Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
                        ),
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                                CurvedAnimation(parent: animationController, curve: Curves.elasticOut),
                              ),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Enhanced Order Summary
                          _buildEnhancedOrderSummary(currentOrderDishes, currentOrderTotal),
                          
                          // Enhanced Search Bar
                          _buildEnhancedSearchBar(searchController, ref),
                          
                          // Enhanced Hero Slideshow
                          _buildEnhancedHeroSlideshow(
                            heroDashboardContent,
                            pageController,
                            currentPage,
                            context,
                          ),
                          
                          // Enhanced Menu Section
                          _buildEnhancedMenuSection(dishesAsync, searchQuery, ref, context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar(BuildContext context, List currentOrderDishes, double currentOrderTotal) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Animated Back Button
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, animation, child) {
              return Transform.scale(
                scale: animation,
                child: Hero(
                  tag: 'back_button_dashboard',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () => context.goNamed(AppRouteNames.tableLogin),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Animated Title
          Expanded(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, animation, child) {
                return Transform.scale(
                  scale: animation,
                  child: Opacity(
                    opacity: animation,
                    child: Text(
                      'Table $tableNumber',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Enhanced Action Buttons
          Row(
            children: [
              _buildActionButton(
                icon: Icons.fastfood_rounded,
                onTap: () => context.goNamed(
                  AppRouteNames.orderStatus,
                  pathParameters: {'tableNumber': tableNumber},
                ),
                delay: 200,
              ),
              
              const SizedBox(width: 12),
              
              _buildActionButton(
                icon: Icons.shopping_cart_rounded,
                onTap: () => context.goNamed(
                  AppRouteNames.customerCart,
                  pathParameters: {'tableNumber': tableNumber},
                ),
                badge: currentOrderDishes.isNotEmpty ? currentOrderDishes.length : null,
                delay: 400,
              ),
            ],
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
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Icon(icon, color: Colors.white, size: 24),
                    if (badge != null)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 300),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, badgeAnimation, child) {
                            return Transform.scale(
                              scale: badgeAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                child: Text(
                                  '$badge',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedOrderSummary(List currentOrderDishes, double currentOrderTotal) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.purple.shade50,
                    Colors.pink.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, iconAnimation, child) {
                      return Transform.scale(
                        scale: iconAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade100, Colors.blue.shade200],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.blue.shade700,
                            size: 28,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(width: 20),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Order',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Items: ${currentOrderDishes.length} | Total: €${currentOrderTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (currentOrderDishes.isNotEmpty)
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween<double>(begin: 0.8, end: 1.2),
                      builder: (context, pulseAnimation, child) {
                        return Transform.scale(
                          scale: pulseAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green.shade400, Colors.green.shade600],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSearchBar(TextEditingController searchController, WidgetRef ref) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade50, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: '🔍 Search your favorite dish...',
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.blue.shade600,
                            size: 24,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                        onSubmitted: (value) {
                          ref.read(dishSearchQueryProvider.notifier).state = value.trim();
                        },
                      ),
                    ),
                    
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            final searchTerm = searchController.text.toLowerCase().trim();
                            ref.read(dishSearchQueryProvider.notifier).state = searchTerm;
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(15),
                            child: Icon(Icons.search_rounded, color: Colors.white, size: 20),
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
      },
    );
  }

  Widget _buildEnhancedHeroSlideshow(
    AsyncValue heroDashboardContent,
    PageController pageController,
    ValueNotifier<int> currentPage,
    BuildContext context,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              margin: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white,
                      title: Row(
                        children: [
                          Icon(Icons.photo_library_rounded, color: Colors.blue.shade600),
                          const SizedBox(width: 12),
                          const Text('Hero Slideshow'),
                        ],
                      ),
                      content: Text('Current image: ${currentPage.value + 1}'),
                      actions: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.blue.shade600],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: heroDashboardContent.when(
                  data: (images) {
                    // Fixed type handling
                    final imagesList = <String>[];
                    for (var entry in images.entries) {
                      if (entry.value is String && (entry.value as String).isNotEmpty) {
                        imagesList.add(entry.value as String);
                      }
                    }
                    
                    if (imagesList.isEmpty) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            colors: [Colors.grey.shade200, Colors.grey.shade300],
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                              SizedBox(height: 12),
                              Text(
                                'No hero images available',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
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
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.4),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Enhanced page indicators
                        if (imagesList.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                imagesList.length,
                                (index) => TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 300),
                                  tween: Tween<double>(
                                    begin: 0.0,
                                    end: currentPage.value == index ? 1.0 : 0.0,
                                  ),
                                  builder: (context, indicatorAnimation, child) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 6.0),
                                      width: 10.0 + (indicatorAnimation * 20.0),
                                      height: 10.0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white.withOpacity(0.6 + (indicatorAnimation * 0.4)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        
                        // Enhanced navigation arrows
                        if (imagesList.length > 1) ...[
                          _buildNavigationArrow(
                            alignment: Alignment.centerLeft,
                            icon: Icons.chevron_left_rounded,
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
                          ),
                          
                          _buildNavigationArrow(
                            alignment: Alignment.centerRight,
                            icon: Icons.chevron_right_rounded,
                            onTap: () {
                              final nextPage = (currentPage.value + 1) % imagesList.length;
                              pageController.animateToPage(
                                nextPage,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade200, Colors.grey.shade300],
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.blue),
                          SizedBox(height: 16),
                          Text('Loading gallery...', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  error: (error, stack) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.red.shade100,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red.shade600),
                          const SizedBox(height: 12),
                          Text(
                            'Error loading images: $error',
                            style: TextStyle(color: Colors.red.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationArrow({
    required Alignment alignment,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedMenuSection(
    AsyncValue dishesAsync,
    String searchQuery,
    WidgetRef ref,
    BuildContext context,
  ) {
    return Expanded(
      child: Column(
        children: [
          // Enhanced Menu Header
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1400),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, animation, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - animation)),
                child: Opacity(
                  opacity: animation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange.shade100, Colors.orange.shade200],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            color: Colors.orange.shade700,
                            size: 28,
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        const Text(
                          'Our Delicious Menu',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        if (searchQuery.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade100, Colors.blue.shade200],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              '🔍 "$searchQuery"',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Enhanced Dishes List
          Expanded(
            child: dishesAsync.when(
              data: (dishes) {
                if (dishes.isEmpty && searchQuery.isNotEmpty) {
                  return _buildEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No dishes found',
                    subtitle: 'Try searching with different keywords',
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dishes.length,
                  itemBuilder: (context, index) {
                    return _buildEnhancedDishCard(dishes[index], index, ref, context);
                  },
                );
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading delicious dishes...',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading menu',
                      style: TextStyle(fontSize: 18, color: Colors.red.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDishCard(dynamic dish, int index, WidgetRef ref, BuildContext context) {
    final dishCount = ref.watch(dishCountInOrderProvider(dish));

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey.shade50],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Enhanced dish image with hero animation
                    Hero(
                      tag: 'dish_${dish.name}_dashboard',
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: dish.imageUrl != null && dish.imageUrl!.isNotEmpty
                              ? Image.network(
                                  dish.imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.grey.shade200, Colors.grey.shade300],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.restaurant_menu_rounded,
                                    color: Colors.grey.shade500,
                                    size: 40,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Enhanced dish details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dish.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          
                          const SizedBox(height: 6),
                          
                          Text(
                            dish.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 10),
                          
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green.shade100, Colors.green.shade200],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  '€${dish.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                              
                              if (dishCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blue.shade100, Colors.blue.shade200],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    '$dishCount in cart',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Enhanced action buttons
                    Column(
                      children: [
                        _buildDishActionButton(
                          icon: Icons.add_shopping_cart_rounded,
                          color: Colors.green,
                          isEnabled: dish.isAvailable,
                          onPressed: dish.isAvailable
                              ? () {
                                  ref.read(currentOrderProvider.notifier).addDish(dish);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text('${dish.name} added to order!'),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                        
                        if (dishCount > 0) ...[
                          const SizedBox(height: 8),
                          _buildDishActionButton(
                            icon: Icons.remove_circle_outline_rounded,
                            color: Colors.red,
                            isEnabled: true,
                            onPressed: () {
                              ref.read(currentOrderProvider.notifier).removeDish(dish);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.info, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text('${dish.name} removed from order!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDishActionButton({
    required IconData icon,
    required Color color,
    required bool isEnabled,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isEnabled && onPressed != null
                ? LinearGradient(
                    colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
                  )
                : null,
            color: !isEnabled || onPressed == null ? Colors.grey.shade200 : null,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isEnabled && onPressed != null 
                  ? color.withOpacity(0.3) 
                  : Colors.grey.shade300,
            ),
            boxShadow: isEnabled && onPressed != null
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: isEnabled && onPressed != null ? color : Colors.grey.shade400,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, animation, child) {
          return Transform.scale(
            scale: animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      color.withOpacity(0.1),
                      color.withOpacity(0.2)
                    ]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 64, color: color.withOpacity(0.6)),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.7),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
