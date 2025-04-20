import 'package:flutter/material.dart';
import 'package:todo_app/ui/signin.dart';
import 'package:todo_app/ui/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFF4F46E5),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF6366F1),
          surface: const Color(0xFF171717),
        ),
      ),
      routes: {
        '/': (context) => const HomeScreen(),
        '/signin': (context) => const SignInScreen(),
      },
      initialRoute: '/',
    );
  }
}

