import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/route_names.dart';

// Safe opacity extension
extension ColorExtensions on Color {
  Color withOpacityFactor(double opacity) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return withAlpha((safeOpacity * 255).round());
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _floatingAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth / 2 - 32;

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
                child: AnimatedBuilder(
                  animation: _floatingAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatingAnimation.value),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildDashboardContent(context, cardWidth),
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
    );
  }

  Widget _buildEnhancedAppBar(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        final safeOpacity = animation.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, -50 * (1 - animation)),
          child: Opacity(
            opacity: safeOpacity,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Enhanced back button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () => context.goNamed(AppRouteNames.login),
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
                          'ADMIN DASHBOARD',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
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
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, double cardWidth) {
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First row of cards
               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildEnhancedDashboardCard(
                      context,
                      icon: Icons.person_rounded,
                      label: 'Waiter\nManagement',
                      color: Colors.blue,
                      width: cardWidth,
                      routeName: AppRouteNames.waiterDashboard,
                      delay: 200,
                    ),
                    const SizedBox(width: 16),
                    _buildEnhancedDashboardCard(
                      context,
                      icon: Icons.account_balance_rounded,
                      label: 'Accounts',
                      color: Colors.green,
                      width: cardWidth,
                      routeName: AppRouteNames.accountsDashboard,
                      delay: 400,
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // Second row of cards
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildEnhancedDashboardCard(
                      context,
                      icon: Icons.restaurant_menu_rounded,
                      label: 'Chef\nDashboard',
                      color: Colors.orange,
                      width: cardWidth,
                      routeName: AppRouteNames.chefDashboard,
                      delay: 600,
                    ),
                    const SizedBox(width: 16),
                    _buildEnhancedDashboardCard(
                      context,
                      icon: Icons.inventory_rounded,
                      label: 'Inventory',
                      color: Colors.purple,
                      width: cardWidth,
                      routeName: AppRouteNames.inventoryDashboard,
                      delay: 800,
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // Admin panel card (full width)
              _buildEnhancedDashboardCard(
                context,
                icon: Icons.admin_panel_settings_rounded,
                label: 'Admin Panel',
                color: Colors.red,
                width: cardWidth * 2 + 16, // Full width with spacing
                routeName: AppRouteNames.adminPanel,
                delay: 1000,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEnhancedDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required double width,
    required String routeName,
    int delay = 0,
    bool isFullWidth = false,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Hero(
            tag: routeName,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.goNamed(routeName),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: width,
                  height: isFullWidth ? 120 : 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacityFactor(0.1),
                        color.withOpacityFactor(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withOpacityFactor(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacityFactor(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 1000 + delay),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        builder: (context, iconAnimation, child) {
                          return Transform.rotate(
                            angle: 0.1 * (1 - iconAnimation),
                            child: Container(
                              padding: EdgeInsets.all(isFullWidth ? 12 : 16),
                              decoration: BoxDecoration(
                                color: color.withOpacityFactor(0.2),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacityFactor(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                icon,
                                size: isFullWidth ? 32 : 40,
                                color: color,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: isFullWidth ? 8 : 12),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: isFullWidth ? 16 : 15,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}