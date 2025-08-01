import 'package:chatbot/components/custom_button.dart';
import 'package:chatbot/components/custom_textfield.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailCtrller = TextEditingController();
  final TextEditingController pwCtrller = TextEditingController();

  final void Function()? onTap;
  LoginScreen({super.key, required this.onTap});

  void login() {
    // login logic
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //App Logo
              const FlutterLogo(size: 80),
        
              const SizedBox(height: 24),
        
              // Welcome Message
              const Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
        
              const SizedBox(height: 32),
        
              // Email TextField
              CustomTextfield(label: "Email", controller: emailCtrller),
        
              const SizedBox(height: 16),
        
              // Password TextField
              CustomTextfield(label: "Password", controller: pwCtrller),
        
              const SizedBox(height: 24),
        
              // Login Button
              CustomButton(
                text: "Login",
                onPressed: () {
                  login();
                },
              ),
        
              const SizedBox(height: 24),
        
              // Sign-up Text with GestureDetector
              Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      "Register Now",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
