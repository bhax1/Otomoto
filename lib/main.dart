import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:otomoto/firebase_options.dart';
import 'package:otomoto/logic/connection_checker.dart';
import 'package:otomoto/staff/screens/staff_login.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager
  await windowManager.ensureInitialized();

  windowManager.setMinimumSize(const Size(1050, 600));
  windowManager.setSize(const Size(1050, 600)); // Set default size
  windowManager.setAlignment(Alignment.center); // Center the window

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ConnectionChecker()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otomoto Car Rental',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: Colors.white, // Light amber background
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black, // Ensures contrast
          elevation: 0,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.amber[700], // Darker amber for buttons
          textTheme: ButtonTextTheme.primary,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // Light amber fill for text fields
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.amber),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.amber[700]!, width: 2),
          ),
          hintStyle: const TextStyle(color: Colors.black),
          labelStyle: const TextStyle(color: Colors.black),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
