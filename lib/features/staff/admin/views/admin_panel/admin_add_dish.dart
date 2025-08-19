import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/models/dish.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/dish/dish_provider.dart';

// Safe opacity extension
extension ColorExtensions on Color {
  Color withOpacityFactor(double opacity) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return withAlpha((safeOpacity * 255).round());
  }
}

class AdminAddDish extends HookConsumerWidget {
  const AdminAddDish({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishAsync = ref.watch(dishesProvider);
    final dishNameController = useTextEditingController();
    final dishPriceController = useTextEditingController();
    final dishDescriptionController = useTextEditingController();
    final dishImageController = useTextEditingController();
    final dishCategoryController = useTextEditingController();
    final dishIngredientsController = useTextEditingController();
    final isAvailable = useState(true);
    
    // Animation controllers
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );
    
    final floatingController = useAnimationController(
      duration: const Duration(milliseconds: 3000),
    );

    final buttonController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    // Animations
    final fadeAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      );
    

    final slideAnimation = 
      Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
    );

    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
      ),
    );

    final floatingAnimation = useAnimation(
      Tween<double>(begin: -4.0, end: 4.0).animate(
        CurvedAnimation(parent: floatingController, curve: Curves.easeInOut),
      ),
    );

    // Start animations
    useEffect(() {
      animationController.forward();
      floatingController.repeat(reverse: true);
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
              _buildEnhancedAppBar(context),
              Expanded(
                child: Transform.translate(
                  offset: Offset(0, floatingAnimation),
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: Transform.scale(
                        scale: scaleAnimation,
                        child: _buildFormContent(
                          context,
                          ref,
                          dishAsync,
                          dishNameController,
                          dishPriceController,
                          dishDescriptionController,
                          dishImageController,
                          dishCategoryController,
                          dishIngredientsController,
                          isAvailable,
                          buttonController,
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
    );
  }

  Widget _buildEnhancedAppBar(BuildContext context) {
    final appBarController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    final appBarAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: appBarController, curve: Curves.easeOut),
      ),
    );

    useEffect(() {
      appBarController.forward();
      return null;
    }, []);

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
                      'ADD NEW DISH',
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
                    const SizedBox(height: 4),
                    Text(
                      'Menu Management System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacityFactor(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
  
  Widget _buildFormContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue dishAsync,
    TextEditingController dishNameController,
    TextEditingController dishPriceController,
    TextEditingController dishDescriptionController,
    TextEditingController dishImageController,
    TextEditingController dishCategoryController,
    TextEditingController dishIngredientsController,
    ValueNotifier<bool> isAvailable,
    AnimationController buttonController,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              // Form header
              _buildFormHeader(),
              
              const SizedBox(height: 32),
              
              // Dish Name Field
              _buildAnimatedTextField(
                controller: dishNameController,
                label: 'Dish Name',
                hint: 'Enter dish name',
                icon: Icons.restaurant_rounded,
                delay: 200,
              ),
              
              const SizedBox(height: 20),
              
              // Price Field
              _buildAnimatedTextField(
                controller: dishPriceController,
                label: 'Price',
                hint: 'Enter price',
                icon: Icons.attach_money_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                delay: 300,
              ),
              
              const SizedBox(height: 20),
              
              // Description Field
              _buildAnimatedTextField(
                controller: dishDescriptionController,
                label: 'Description',
                hint: 'Enter dish description',
                icon: Icons.description_rounded,
                maxLines: 3,
                delay: 400,
              ),
              
              const SizedBox(height: 20),
              
              // Image URL Field
              _buildAnimatedTextField(
                controller: dishImageController,
                label: 'Image URL',
                hint: 'Enter image URL',
                icon: Icons.image_rounded,
                delay: 500,
              ),
              
              const SizedBox(height: 20),
              
              // Category Field
              _buildAnimatedTextField(
                controller: dishCategoryController,
                label: 'Category',
                hint: 'Enter category',
                icon: Icons.category_rounded,
                delay: 600,
              ),
              
              const SizedBox(height: 20),
              
              // Ingredients Field
              _buildAnimatedTextField(
                controller: dishIngredientsController,
                label: 'Ingredients',
                hint: 'Enter ingredients (comma separated)',
                icon: Icons.grass_rounded,
                delay: 700,
              ),
              
              const SizedBox(height: 24),
              
              // Availability Switch
              _buildAnimatedSwitch(isAvailable, 800),
              
              const SizedBox(height: 40),
              
              // Submit Button
              _buildAnimatedSubmitButton(
                context,
                ref,
                dishAsync,
                dishNameController,
                dishPriceController,
                dishDescriptionController,
                dishImageController,
                dishCategoryController,
                dishIngredientsController,
                isAvailable,
                buttonController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    final headerController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    final headerAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: headerController, curve: Curves.easeOutBack),
      ),
    );

    useEffect(() {
      Future.delayed(const Duration(milliseconds: 300), () {
        headerController.forward();
      });
      return null;
    }, []);

    return Transform.scale(
      scale: headerAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.red.shade50],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
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
                Icons.add_circle_rounded,
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
                    'Create New Dish',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add a delicious dish to your menu',
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

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int delay = 0,
  }) {
    final fieldController = useAnimationController(
      duration: Duration(milliseconds: 600 + delay),
    );

    useEffect(() {
      Future.delayed(Duration(milliseconds: 500 + delay), () {
        fieldController.forward();
      });
      return null;
    }, []);

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
                  CurvedAnimation(parent: fieldController, curve: Curves.easeOut),
                ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(parent: fieldController, curve: Curves.easeOutBack),
                ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacityFactor(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.red.shade400],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              labelStyle: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSwitch(ValueNotifier<bool> isAvailable, int delay) {
    final switchController = useAnimationController(
      duration: Duration(milliseconds: 600 + delay),
    );

    final switchAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: switchController, curve: Curves.easeOutBack),
      ),
    );

    useEffect(() {
      Future.delayed(Duration(milliseconds: 500 + delay), () {
        switchController.forward();
      });
      return null;
    }, []);

    return Transform.scale(
      scale: switchAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.teal.shade400],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Dish Available',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            Switch(
              value: isAvailable.value,
              onChanged: (bool value) {
                isAvailable.value = value;
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSubmitButton(
    BuildContext context,
    WidgetRef ref,
    AsyncValue dishAsync,
    TextEditingController dishNameController,
    TextEditingController dishPriceController,
    TextEditingController dishDescriptionController,
    TextEditingController dishImageController,
    TextEditingController dishCategoryController,
    TextEditingController dishIngredientsController,
    ValueNotifier<bool> isAvailable,
    AnimationController buttonController,
  ) {
    final submitController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    final submitAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: submitController, curve: Curves.easeOutBack),
      ),
    );

    useEffect(() {
      Future.delayed(const Duration(milliseconds: 1000), () {
        submitController.forward();
      });
      return null;
    }, []);

    return Transform.scale(
      scale: submitAnimation,
      child: GestureDetector(
        onTapDown: (_) => buttonController.forward(),
        onTapUp: (_) => buttonController.reverse(),
        onTapCancel: () => buttonController.reverse(),
        onTap: () async {
          if (dishNameController.text.isEmpty || dishPriceController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Please fill in at least the dish name and price.')),
                  ],
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            return;
          }

          final dish = Dish(
            id: 'dish_00${dishAsync.value!.length + 1}',
            name: dishNameController.text,
            price: double.parse(dishPriceController.text),
            description: dishDescriptionController.text,
            imageUrl: dishImageController.text,
            category: dishCategoryController.text,
            ingredients: dishIngredientsController.text,
            isAvailable: isAvailable.value,
          );

          ref.read(dishAddProvider(dish));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Dish "${dish.name}" added successfully!')),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          context.goNamed(AppRouteNames.adminPanel);
        },
        child: AnimatedBuilder(
          animation: buttonController,
          builder: (context, child) {
            final scale = 1.0 - (buttonController.value * 0.05);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.red.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacityFactor(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Add Dish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
