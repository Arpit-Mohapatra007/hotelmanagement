import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hotelmanagment/customer/dashboard.dart';
import 'package:hotelmanagment/customer/table_number.dart';
import 'package:hotelmanagment/staff/accountant/dashboard.dart';
import 'package:hotelmanagment/staff/admin/dashboard.dart';
import 'package:hotelmanagment/staff/chef/dashboard.dart';
import 'package:hotelmanagment/staff/inventory_managment/dashboard.dart';

void main() {
 runApp(
  const App()
 );
}

class App extends StatelessWidget {
  const App({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home:  CustomerDashboard(),
    );
  }
}

