import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/table/table_provider.dart';

class TableLogin extends HookConsumerWidget {
  const TableLogin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableController = useTextEditingController();
    final isLoading = useState(false);

    void showErrorDialog(String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => context.goNamed(AppRouteNames.home),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            context.goNamed(AppRouteNames.home);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.restaurant_menu, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              Text(
                'Please Enter Your Table Number',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: tableController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Eg. T001',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: isLoading.value
                    ? null
                    : () async {
                        final tableNum = tableController.text.trim();
                        if (tableNum.isEmpty) {
                          showErrorDialog('Please enter a table number.');
                          return;
                        }

                        isLoading.value = true;
                        try {
                          final exists = await ref.read(
                              checkTableExistsProvider(tableNum).future);

                          if (context.mounted) {
                            if (exists) {
                              context.goNamed(
                                AppRouteNames.customerDashboard,
                                pathParameters: {'tableNumber': tableNum},
                              );
                            } else {
                              showErrorDialog(
                                  'Table "$tableNum" was not found. Please check the number and try again.');
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showErrorDialog('An error occurred: $e');
                          }
                        } finally {
                          if (context.mounted) {
                            isLoading.value = false;
                          }
                        }
                      },
                child: isLoading.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                      )
                    : const Text('Proceed', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
