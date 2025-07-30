import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelmanagement/core/router/router.dart';

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
          context.goNamed(
            AppRouteNames.tableLogin
          );
            }, 
        child: const Text('Customer')
      ),
        TextButton(
          onPressed: (){
            context.goNamed(
              AppRouteNames.login
            );
             }, 
          child: const Text('Staff')
        ),
    ],
   ),
   )
  );
 }
}