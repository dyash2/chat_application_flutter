import 'dart:developer';
import 'package:chatbot/firebase_options.dart';
import 'package:chatbot/themes/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chatbot/services/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load the environment variables
  await dotenv.load(fileName: ".env");

  //try to initalize
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }
  // print the error here
  catch (e) {
    log("Initialization Error : $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot Application',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: AuthGate(),
    );
  }
}
