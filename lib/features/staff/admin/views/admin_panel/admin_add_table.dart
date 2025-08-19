import 'package:flutter/material.dart' hide Table;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/constants/table_status.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';
import '../../../../../core/models/table.dart';

// Safe opacity extension
extension ColorExtensions on Color {
  Color withOpacityFactor(double opacity) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return withAlpha((safeOpacity * 255).round());
  }
}

class AdminAddTable extends HookConsumerWidget {
  const AdminAddTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableAsync = ref.watch(tablesProvider);
    final tableNumberController = useTextEditingController();
    final capacityController = useTextEditingController();
    
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
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(parent: animationController, curve: Curves.easeOut),
                              ),
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
                                  CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
                                ),
                      child: Transform.scale(
                        scale: scaleAnimation,
                        child: _buildFormContent(
                          context,
                          ref,
                          tableAsync,
                          tableNumberController,
                          capacityController,
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
                      'ADD NEW TABLE',
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

  Widget _buildFormContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue tableAsync,
    TextEditingController tableNumberController,
    TextEditingController capacityController,
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
              
              // Table Number Field
              _buildAnimatedTextField(
                controller: tableNumberController,
                label: 'Table Number',
                hint: 'Eg. T001',
                icon: Icons.table_bar_rounded,
                delay: 200,
              ),
              
              const SizedBox(height: 24),
              
              // Capacity Field
              _buildAnimatedTextField(
                controller: capacityController,
                label: 'Capacity',
                hint: 'Enter table capacity',
                icon: Icons.people_rounded,
                keyboardType: TextInputType.number,
                delay: 400,
              ),
              
              const SizedBox(height: 40),
              
              // Submit Button
              _buildAnimatedSubmitButton(
                context,
                ref,
                tableAsync,
                tableNumberController,
                capacityController,
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
            colors: [Colors.blue.shade50, Colors.purple.shade50],
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
                  colors: [Colors.blue.shade400, Colors.purple.shade400],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacityFactor(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_business_rounded,
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
                    'Create New Table',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add a new table to your restaurant',
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
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
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

  Widget _buildAnimatedSubmitButton(
    BuildContext context,
    WidgetRef ref,
    AsyncValue tableAsync,
    TextEditingController tableNumberController,
    TextEditingController capacityController,
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
      Future.delayed(const Duration(milliseconds: 900), () {
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
          if (tableNumberController.text.isEmpty || capacityController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Please fill in all fields.')),
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

          final capacity = int.tryParse(capacityController.text);
          if (capacity == null || capacity <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Please enter a valid capacity.')),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            return;
          }

          final tableNumber = tableNumberController.text;
          final newTable = Table(
            tableId: '${tableAsync.value!.length + 1}',
            tableNumber: tableNumber,
            status: TableStatus.available.name,
            orders: [],
            currentBill: 0.0,
            capacity: capacity,
            sessionInfo: '',
          );

          ref.read(addTableProvider(newTable));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Table $tableNumber added successfully!')),
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
                    colors: [Colors.blue.shade400, Colors.purple.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacityFactor(0.3),
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
                      'Add Table',
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
