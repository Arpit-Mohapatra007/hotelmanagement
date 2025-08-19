import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/staff/admin/provider/admin_provider.dart';

// Safe opacity extension
extension ColorExtensions on Color {
  Color withOpacityFactor(double opacity) {
    final safeOpacity = opacity.clamp(0.0, 1.0);
    return withAlpha((safeOpacity * 255).round());
  }
}

class AdminFinanceReport extends HookConsumerWidget {
  const AdminFinanceReport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalTipsAsyncValue = ref.watch(getTotalTipsStreamProvider);
    final totalFoodSaleAsyncValue = ref.watch(getTotalFoodSaleStreamProvider);
    final revenueAsyncValue = ref.watch(getRevenueStreamProvider);
    final taxAsyncValue = ref.watch(getTaxStreamProvider);
    final inventoryExpenditureAsyncValue = ref.watch(getInventoryExpenditureStreamProvider);
    final expenditureAsyncValue = ref.watch(getExpenditureStreamProvider);
    final netProfitAsyncValue = ref.watch(getNetProfitStreamProvider);

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

    final headerController = useAnimationController(
      duration: const Duration(milliseconds: 800),
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

    final headerAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: headerController, curve: Curves.easeOutBack),
      ),
    );

    // ALL EFFECTS IN BUILD METHOD
    useEffect(() {
      animationController.forward();
      floatingController.repeat(reverse: true);
      appBarController.forward();
      
      Future.delayed(const Duration(milliseconds: 300), () {
        headerController.forward();
      });
      
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
              _buildEnhancedAppBar(context, appBarAnimation),
              Expanded(
                child: Transform.translate(
                  offset: Offset(0, floatingAnimation),
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: _buildFinanceContent(
                        context,
                        totalTipsAsyncValue,
                        totalFoodSaleAsyncValue,
                        revenueAsyncValue,
                        taxAsyncValue,
                        inventoryExpenditureAsyncValue,
                        expenditureAsyncValue,
                        netProfitAsyncValue,
                        headerAnimation,
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

  Widget _buildEnhancedAppBar(BuildContext context, double appBarAnimation) {
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
                      'FINANCE REPORT',
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

  Widget _buildFinanceContent(
    BuildContext context,
    AsyncValue<double> totalTipsAsyncValue,
    AsyncValue<double> totalFoodSaleAsyncValue,
    AsyncValue<double> revenueAsyncValue,
    AsyncValue<double> taxAsyncValue,
    AsyncValue<double> inventoryExpenditureAsyncValue,
    AsyncValue<double> expenditureAsyncValue,
    AsyncValue<double> netProfitAsyncValue,
    double headerAnimation,
  ) {
    final financeItems = [
      _FinanceItem(
        title: 'Total Tips',
        asyncValue: totalTipsAsyncValue,
        icon: Icons.attach_money_rounded,
        color: Colors.green,
      ),
      _FinanceItem(
        title: 'Total Food Sale',
        asyncValue: totalFoodSaleAsyncValue,
        icon: Icons.restaurant_rounded,
        color: Colors.blue,
      ),
      _FinanceItem(
        title: 'Revenue',
        asyncValue: revenueAsyncValue,
        icon: Icons.trending_up_rounded,
        color: Colors.purple,
      ),
      _FinanceItem(
        title: 'Tax (15%)',
        asyncValue: taxAsyncValue,
        icon: Icons.receipt_rounded,
        color: Colors.orange,
      ),
      _FinanceItem(
        title: 'Inventory Expenditure',
        asyncValue: inventoryExpenditureAsyncValue,
        icon: Icons.inventory_2_rounded,
        color: Colors.red,
      ),
      _FinanceItem(
        title: 'Total Expenditure',
        asyncValue: expenditureAsyncValue,
        icon: Icons.money_off_rounded,
        color: Colors.deepOrange,
      ),
      _FinanceItem(
        title: 'Net Profit',
        asyncValue: netProfitAsyncValue,
        icon: Icons.account_balance_rounded,
        color: Colors.teal,
      ),
    ];

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
        child: Column(
          children: [
            // Header
            _buildReportHeader(headerAnimation),
            
            // Finance tiles
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: financeItems.length,
                itemBuilder: (context, index) {
                  return AnimatedFinanceTile(
                    item: financeItems[index],
                    index: index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader(double headerAnimation) {
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
                Icons.pie_chart_rounded,
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
                    'Financial Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete financial analysis and metrics',
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
}

// Separate HookWidget for individual finance tiles
class AnimatedFinanceTile extends HookWidget {
  final _FinanceItem item;
  final int index;

  const AnimatedFinanceTile({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final tileController = useAnimationController(
      duration: Duration(milliseconds: 600 + (index * 100)),
    );

    final tileAnimation = 
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: tileController, curve: Curves.easeOutBack),
    );

    final slideAnimation = 
      Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: tileController, curve: Curves.easeOut),
    );

    useEffect(() {
      Future.delayed(Duration(milliseconds: 400 + (index * 100)), () {
        tileController.forward();
      });
      return null;
    }, []);

    return SlideTransition(
      position: slideAnimation,
      child: ScaleTransition(
        scale: tileAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                item.color.withOpacityFactor(0.05),
                item.color.withOpacityFactor(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.color.withOpacityFactor(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: item.color.withOpacityFactor(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.color.withOpacityFactor(0.2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withOpacityFactor(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Title and Value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      item.asyncValue.when(
                        data: (value) => TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1500),
                          tween: Tween<double>(begin: 0.0, end: value),
                          builder: (context, animatedValue, child) {
                            return Text(
                              '€${animatedValue.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: item.color,
                              ),
                            );
                          },
                        ),
                        loading: () => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: item.color.withOpacityFactor(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(item.color),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: item.color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        error: (error, stack) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacityFactor(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_rounded,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Error',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FinanceItem {
  final String title;
  final AsyncValue<double> asyncValue;
  final IconData icon;
  final Color color;

  const _FinanceItem({
    required this.title,
    required this.asyncValue,
    required this.icon,
    required this.color,
  });
}
