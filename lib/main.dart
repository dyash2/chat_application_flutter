import 'package:chatbot/auth/login_register.dart';
import 'package:chatbot/screens/login_screen.dart';
import 'package:chatbot/themes/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot Application',
      debugShowCheckedModeBanner: false,
      // theme: themes,
      home: LoginRegister(),
    );
  }
}


