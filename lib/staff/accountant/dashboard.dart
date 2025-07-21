import 'package:flutter/material.dart';

class AccountsDashboard extends StatelessWidget {
  const AccountsDashboard({super.key});

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
            const Text('Bills in Progress'),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Table $index'),
                    subtitle: const Text('USD 100'),
                    trailing: TextButton(
                      onPressed: (){
                        // Handle bill payment
                      }, child: const Text('Print Bill'),),
                  );
                }
              ),
            ),
            const Text('Bills Paid'),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Table $index'),
                    subtitle: const Text('USD 100'),
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