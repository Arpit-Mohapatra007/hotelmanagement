import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/models/dish.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/dish/dish_provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Dish'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: dishNameController,
                decoration: const InputDecoration(labelText: 'Dish Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dishPriceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dishDescriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dishImageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dishCategoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dishIngredientsController,
                decoration: const InputDecoration(labelText: 'Ingredients (comma separated)'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Is Available'),
                value: isAvailable.value,
                onChanged: (bool value) {
                  isAvailable.value = value;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (dishNameController.text.isEmpty || dishPriceController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in at least the dish name and price.')),
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
                 context.goNamed(
                  AppRouteNames.adminPanel
                 );
                },
                child: const Text('Add Dish')
              )
            ],
          ),
        ),
      ),
    );
  }
}
