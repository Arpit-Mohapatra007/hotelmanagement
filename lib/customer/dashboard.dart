import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CustomerDashboard extends HookWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Number: 1'),
      ),
      body: Column(
        children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded( // Added Expanded to prevent overflow
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () {
                  // Handle search action
                },
                child: Icon(Icons.search),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
          GestureDetector(
            onTap: () {
              //Hot Deal or Bestseller item 
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.95,
              color: Colors.grey[200],
            ),
          ),
        const SizedBox(height: 10.0),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Example item count
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item ${index + 1}'),
                  subtitle: Text('Description of item ${index + 1}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Only take needed space
                    children: [
                      IconButton(
                        icon: Icon(Icons.add_shopping_cart),
                        color: Colors.green,
                        onPressed: () {
                          // Handle add to cart action
                          
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle),
                        color: Colors.red,
                        onPressed: () {
                          // Handle remove action
                          
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ]
      ),
    );
  }
}