import 'package:chatbot/services/auth/login_register.dart';
import 'package:chatbot/screens/users_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            return UsersListScreen();
          }
          // user is NOT logged in
          else {
            return LoginRegister();
          }
        },
      ),
    );
  }
}
