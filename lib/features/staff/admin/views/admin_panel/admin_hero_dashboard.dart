import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotelmanagement/core/router/route_names.dart';
import 'package:hotelmanagement/features/staff/admin/provider/admin_provider.dart';

class AdminHeroDashboard extends HookConsumerWidget {
  const AdminHeroDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hero1textController = useTextEditingController();
    final hero2textController = useTextEditingController();
    final hero3textController = useTextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Hero Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            context.goNamed(AppRouteNames.adminPanel);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: hero1textController,
                decoration: InputDecoration(
                  hintText: 'Paste URL here'
                ),
              ),
              TextField(
                controller: hero2textController,
                decoration: InputDecoration(
                  hintText: 'Paste URL here'
                ),
              ),
              TextField(
                controller: hero3textController,
                decoration: InputDecoration(
                  hintText: 'Paste URL here'
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final heroUrls = {
                    'h1': hero1textController.text,
                    'h2': hero2textController.text,
                    'h3': hero3textController.text,
                  };
                  ref.read(saveHeroImageUrlProvider(heroUrls).future);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hero images updated successfully!')),
                  );
                  context.goNamed(AppRouteNames.adminPanel);
                },
                child: const Text('Save'),
              ),
            ]
          ),
        )
      )
    );
  }
}