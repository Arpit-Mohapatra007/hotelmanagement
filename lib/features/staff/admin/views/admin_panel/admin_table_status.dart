import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

// Safe opacity extension
extension ColorExtensions on Color {
  Color withOpacityFactor(double opacity) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return withAlpha((safeOpacity * 255).round());
  }
}

class AdminTableStatus extends HookConsumerWidget {
  const AdminTableStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableAsync = ref.watch(tablesProvider);
    
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
                      child: _buildTableStatusContent(
                        context, 
                        ref, 
                        tableAsync, 
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
                      'TABLE STATUS',
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

  Widget _buildTableStatusContent(
    BuildContext context, 
    WidgetRef ref, 
    AsyncValue tableAsync,
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
        child: tableAsync.when(
          data: (tables) {
            if (tables.isEmpty) {
              return _buildEmptyState(emptyAnimation);
            }
            
            return Column(
              children: [
                // Header
                _buildStatusHeader(tables, headerAnimation),
                
                // Tables list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      final table = tables[index];
                      return AnimatedTableStatusCard(
                        table: table,
                        index: index,
                      );
                    },
                  ),
                ),
              ],
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
                  'Loading table status...',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ],
            ),
          ),
          error: (error, stack) => Center(
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
                  'Error loading table status',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(List tables, double headerAnimation) {
    // Calculate status counts
    final availableCount = tables.where((table) => table.status == 'available').length;
    final occupiedCount = tables.where((table) => table.status == 'occupied').length;
    final reservedCount = tables.where((table) => table.status == 'reserved').length;

    return Transform.scale(
      scale: headerAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: Column(
          children: [
            // Main header
            Row(
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
                    Icons.dashboard_rounded,
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
                        'Table Status Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tables.length} tables total',
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
            
            const SizedBox(height: 16),
            
            // Status summary
            Row(
              children: [
                Expanded(
                  child: _buildStatusSummaryCard(
                    'Available',
                    availableCount,
                    Colors.green,
                    Icons.check_circle_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusSummaryCard(
                    'Occupied',
                    occupiedCount,
                    Colors.red,
                    Icons.people_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusSummaryCard(
                    'Reserved',
                    reservedCount,
                    Colors.orange,
                    Icons.schedule_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSummaryCard(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacityFactor(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacityFactor(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
                color: Colors.blue.withOpacityFactor(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.table_restaurant_outlined,
                size: 80,
                color: Colors.blue.withOpacityFactor(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No tables found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add tables to monitor their status',
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
}

class AnimatedTableStatusCard extends HookWidget {
  final dynamic table;
  final int index;

  const AnimatedTableStatusCard({
    super.key,
    required this.table,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final cardController = useAnimationController(
      duration: Duration(milliseconds: 600 + (index * 100)),
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

    final statusColor = _getStatusColor(table.status);
    final statusIcon = _getStatusIcon(table.status);

    return SlideTransition(
      position: slideAnimation,
      child: ScaleTransition(
        scale: cardAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withOpacityFactor(0.05),
                statusColor.withOpacityFactor(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusColor.withOpacityFactor(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacityFactor(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Status indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacityFactor(0.2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacityFactor(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Table details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Table ${table.tableNumber}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Capacity: ${table.capacity} people',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacityFactor(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacityFactor(0.5)),
                        ),
                        child: Text(
                          table.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Current bill (if applicable)
                if (table.currentBill > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Current Bill',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '€${table.currentBill.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'occupied':
        return Colors.red;
      case 'reserved':
        return Colors.orange;
      case 'cleaning':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle_rounded;
      case 'occupied':
        return Icons.people_rounded;
      case 'reserved':
        return Icons.schedule_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}
