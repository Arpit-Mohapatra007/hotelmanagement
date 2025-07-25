import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelmanagement/features/customer/views/customer_dashboard.dart';


void main() async {
 WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  
 runApp(
  ProviderScope(
    child: const App()
    )
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

