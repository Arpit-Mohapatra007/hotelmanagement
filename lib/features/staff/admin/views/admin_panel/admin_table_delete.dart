import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmanagement/features/dish/dish_provider.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

class AdminTableDelete extends ConsumerWidget {
  const AdminTableDelete({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableAsync = ref.watch(tablesProvider);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.goNamed(AppRouteNames.adminPanel),
        ),
        title: const Text('Delete Table'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a Table to delete:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tableAsync.when(
                data: (tables) {
                  if (tables.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No tables available',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      final table = tables[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange[100],
                            child: Icon(
                              Icons.restaurant_menu,
                              color: Colors.orange[700],
                            ),
                          ),
                          title: Text(
                            table.tableNumber,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('Capacity: ${table.capacity.toString()}'),
                          trailing: 
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: (){
                                  ref.read(deleteTableProvider(table.tableNumber));
                                })
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(dishesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
