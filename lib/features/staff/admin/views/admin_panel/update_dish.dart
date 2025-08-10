import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/models/dish.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/dish/dish_provider.dart';

class AdminUpdateDish extends HookConsumerWidget {
  final String dishId;
  const AdminUpdateDish({super.key, required this.dishId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
     final asyncDish = ref.watch(dishByIdProvider(dishId));

    return asyncDish.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
      data: (dishData) {
         final dishNameController = useTextEditingController(text: dishData?.name);
        final dishPriceController =
            useTextEditingController(text: dishData?.price.toString());
        final dishDescriptionController =
            useTextEditingController(text: dishData?.description);
        final dishImageController =
            useTextEditingController(text: dishData?.imageUrl);
        final dishCategoryController =
            useTextEditingController(text: dishData?.category);
        final dishIngredientsController =
            useTextEditingController(text: dishData?.ingredients);
        final dishIsAvailable = useState(dishData?.isAvailable);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Update Dish'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                 context.goNamed(AppRouteNames.adminPanel); 
              },
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
                    value: dishIsAvailable.value!,
                    onChanged: (bool value) {
                      dishIsAvailable.value = value;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(dishUpdateProvider({
                        'dishId': dishId,
                        'updatedDish': Dish(
                          id: dishId,
                          name: dishNameController.text,
                          price: double.parse(dishPriceController.text),
                          description: dishDescriptionController.text,
                          imageUrl: dishImageController.text,
                          category: dishCategoryController.text,
                          ingredients: dishIngredientsController.text,
                          isAvailable: dishIsAvailable.value!, 
                        )
                    }));
                      context.goNamed(AppRouteNames.adminPanel);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dish updated successfully!')),);
                    },
                    child: const Text('Update Dish'),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}