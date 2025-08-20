import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/dialogs/delete_dish_dialog.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/features/dish/dish_provider.dart';

// Safe opacity extension
extension ColorExtensions on Color {
  Color withOpacityFactor(double opacity) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return withAlpha((safeOpacity * 255).round());
  }
}

class AdminUpdateDishView extends HookConsumerWidget {
  const AdminUpdateDishView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishAsync = ref.watch(dishesProvider);
    
    // ALL ANIMATION CONTROLLERS IN BUILD METHOD
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );
    
    final floatingController = useAnimationController(
      duration: const Duration(milliseconds: 3000),
    );

    final appBarController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    final iconController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    final headerController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    final emptyController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    final fadeAnimation = 
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      );

    final slideAnimation = 
      Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
      );

    final floatingAnimation = useAnimation(
      Tween<double>(begin: -4.0, end: 4.0).animate(
        CurvedAnimation(parent: floatingController, curve: Curves.easeInOut),
      ),
    );

    final appBarAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: appBarController, curve: Curves.easeOut),
      ),
    );

    final rotationAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: iconController, curve: Curves.elasticOut),
      ),
    );

    final headerAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: headerController, curve: Curves.easeOutBack),
      ),
    );

    final emptyAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: emptyController, curve: Curves.easeOutBack),
      ),
    );

    useEffect(() {
      animationController.forward();
      floatingController.repeat(reverse: true);
      appBarController.forward();
      iconController.forward();
      
      Future.delayed(const Duration(milliseconds: 300), () {
        headerController.forward();
      });
      
      emptyController.forward();
      
      return null;
    }, []);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF9068BE),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildEnhancedAppBar(context, appBarAnimation, rotationAnimation),
              Expanded(
                child: Transform.translate(
                  offset: Offset(0, floatingAnimation),
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: _buildDishUpdateContent(
                        context, 
                        ref, 
                        dishAsync, 
                        headerAnimation, 
                        emptyAnimation,
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

  Widget _buildEnhancedAppBar(
    BuildContext context, 
    double appBarAnimation, 
    double rotationAnimation,
  ) {
    return Transform.translate(
      offset: Offset(0, -50 * (1 - appBarAnimation)),
      child: Opacity(
        opacity: appBarAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Enhanced back button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () => context.goNamed(AppRouteNames.adminPanel),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacityFactor(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacityFactor(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacityFactor(0.1),
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
              
              // Title
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'UPDATE DISH',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacityFactor(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDishUpdateContent(
    BuildContext context, 
    WidgetRef ref, 
    AsyncValue dishAsync,
    double headerAnimation,
    double emptyAnimation,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacityFactor(0.15),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: dishAsync.when(
          data: (dishes) {
            return Column(
              children: [
                // Header
                _buildUpdateHeader(dishes.length, headerAnimation),
                
                // Dishes list or empty state
                Expanded(
                  child: dishes.isEmpty 
                    ? _buildEmptyState(emptyAnimation)
                    : _buildDishesList(context, ref, dishes),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading dishes...',
                  style: TextStyle(color: Colors.orange, fontSize: 16),
                ),
              ],
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withOpacityFactor(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading dishes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.withOpacityFactor(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  style: TextStyle(
                    color: Colors.red.withOpacityFactor(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(dishesProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateHeader(int dishCount, double headerAnimation) {
    return Transform.scale(
      scale: headerAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.red.shade50],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.red.shade400],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacityFactor(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_document,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update Dishes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dishCount > 0 
                        ? 'Select a dish to edit or delete'
                        : 'No dishes available to update',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(double emptyAnimation) {
    return Transform.scale(
      scale: emptyAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacityFactor(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu_outlined,
                size: 80,
                color: Colors.orange.withOpacityFactor(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No dishes available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add dishes first before updating them',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishesList(BuildContext context, WidgetRef ref, List dishes) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        final dish = dishes[index];
        return AnimatedDishCard(
          dish: dish,
          index: index,
          onEdit: () => context.goNamed(
            AppRouteNames.adminUpdateDish,
            extra: dish.id, 
            ),
          onDelete: () async {
            final shouldDelete = await showDeleteDishDialog(context, dish: dish);
            if (!shouldDelete) return;
            
            // Call the provider to remove the dish
            ref.read(dishRemoveProvider(dish.id));

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Dish "${dish.name}" deleted successfully!')),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Separate HookWidget for individual dish cards
class AnimatedDishCard extends HookWidget {
  final dynamic dish;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AnimatedDishCard({
    super.key,
    required this.dish,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cardController = useAnimationController(
      duration: Duration(milliseconds: 600 + (index * 100)),
    );

    final deleteController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    final editController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    final cardAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: cardController, curve: Curves.easeOutBack),
      );

    final slideAnimation = 
      Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: cardController, curve: Curves.easeOut),
      );

    useEffect(() {
      Future.delayed(Duration(milliseconds: 400 + (index * 100)), () {
        cardController.forward();
      });
      return null;
    }, []);

    return SlideTransition(
      position: slideAnimation,
      child: ScaleTransition(
        scale: cardAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.withOpacityFactor(0.05),
                Colors.red.withOpacityFactor(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.orange.withOpacityFactor(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacityFactor(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Dish icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacityFactor(0.2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacityFactor(0.3),
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
                
                // Dish details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.name,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '€${dish.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      if (dish.description != null && dish.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          dish.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit button
                    GestureDetector(
                      onTapDown: (_) => editController.forward(),
                      onTapUp: (_) => editController.reverse(),
                      onTapCancel: () => editController.reverse(),
                      onTap: onEdit,
                      child: AnimatedBuilder(
                        animation: editController,
                        builder: (context, child) {
                          final scale = 1.0 - (editController.value * 0.1);
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacityFactor(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Delete button
                    GestureDetector(
                      onTapDown: (_) => deleteController.forward(),
                      onTapUp: (_) => deleteController.reverse(),
                      onTapCancel: () => deleteController.reverse(),
                      onTap: onDelete,
                      child: AnimatedBuilder(
                        animation: deleteController,
                        builder: (context, child) {
                          final scale = 1.0 - (deleteController.value * 0.1);
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.red.shade400, Colors.red.shade600],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacityFactor(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.delete_forever_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
