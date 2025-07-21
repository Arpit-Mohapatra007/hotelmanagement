import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
 const HomePage({super.key});

 @override
 Widget build(BuildContext context) {
  return Scaffold(
   body: Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
       TextButton(
        onPressed: (){
          // This is where you would handle the button press for Customer
        }, 
        child: const Text('Customer')
      ),
        TextButton(
          onPressed: (){
            // This is where you would handle the button press for Staff
          }, 
          child: const Text('Staff')
        ),
    ],
   ),
   )
  );
 }
}