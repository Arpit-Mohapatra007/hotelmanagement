import 'package:flutter/material.dart' hide Table;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

import '../../../../../core/models/table.dart';
class AdminAddTable extends HookConsumerWidget {
  const AdminAddTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableAsync = ref.watch(tablesProvider);
    final tableNumberController = useTextEditingController();
    final capacityController = useTextEditingController();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Table'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.goNamed(
            AppRouteNames.adminPanel
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: tableNumberController,
                decoration: const InputDecoration(
                  labelText: 'Table Number',
                  hintText: 'Eg.T001',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                   if (tableNumberController.text.isEmpty || capacityController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all fields.')),
                    );
                    return;
                  }
                  final tableNumber = tableNumberController.text;
                  final capacity = int.parse(capacityController.text);
                  final newTable = Table(
                    tableId: '${tableAsync.value!.length + 1}',
                    tableNumber: tableNumber,
                    status: 'Available',
                    orders: [],
                    currentBill: 0.0,
                    capacity: capacity,
                    sessionInfo: '',
                  );       
                  ref.read(addTableProvider(newTable));
                  context.goNamed(
                    AppRouteNames.adminPanel
                  );
                },
                child: const Text('Add Table'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
