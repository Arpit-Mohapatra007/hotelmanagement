import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TableNumber extends HookWidget {
  const TableNumber({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    return Scaffold(
      body: Center(
        child: Container(
          width: 300.0,
          height: 150.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ), // Added missing comma here
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
            maxLength: 2,
            decoration: InputDecoration(
              hintText: 'Table Number',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
          ),
        ),
      ),
    );
  }
}