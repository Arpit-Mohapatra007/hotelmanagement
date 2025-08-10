import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

class AdminTableStatus extends ConsumerWidget {
  const AdminTableStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableAsync = ref.watch(tablesProvider);
    return tableAsync.when(
      data: (tables) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: (){
                context.goNamed(AppRouteNames.adminPanel);
              }, 
              icon: Icon(Icons.arrow_back_ios_new_rounded)
              ),
            title: const Text('Table Status')
            ),
          body: ListView.builder(
            itemCount: tables.length,
            itemBuilder: (context, index) => ListTile(
              title: Text('Table ${tables[index].tableNumber}'),
              subtitle: Text('Status: ${tables[index].status}'),
              ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}