import 'package:flutter/material.dart';

class ChefDashboard extends StatelessWidget {
  const ChefDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NAME'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Orders'),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Item $index'),
                    subtitle: const Text('Recipe details here'),
                    trailing: TextButton(
                      onPressed: (){
                        // Handle bill payment
                      }, child: const Text('Deliver'),),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}