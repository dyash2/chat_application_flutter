import 'package:chatbot/services/auth/auth_service.dart';
import 'package:chatbot/components/custom_button.dart';
import 'package:chatbot/components/custom_textfield.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController confirmpwController = TextEditingController();
  final void Function()? onTap;

  RegisterScreen({super.key, required this.onTap});

  void register(BuildContext context) {
    final authService = AuthService();

    if (pwController.text == confirmpwController.text) {
      try {
        authService.signUpWithEmailPassword(
          emailController.text,
          pwController.text,
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(title: Text("Passwords don't match")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                const Text(
                  "Create an account 👤",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
          
                // Subtitle
                const Text(
                  "Let's get started by creating your account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
          
                // Email Field
                CustomTextfield(
                  label: "Email",
                  controller: emailController,
                ),
                const SizedBox(height: 16),
          
                // Password Field
                CustomTextfield(
                  label: "Password",
                  controller: pwController,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
          
                // Confirm Password Field
                CustomTextfield(
                  label: "Confirm Password",
                  controller: confirmpwController,
                  obscureText: true,
                ),
                const SizedBox(height: 24),
          
                // Register Button
                CustomButton(
                  text: "REGISTER",
                  onPressed: () => register(context),
                ),
                const SizedBox(height: 16),
          
                // OR Divider
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
          
                // Login Redirect
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    GestureDetector(
                      onTap: onTap,
                      child: Text(
                        " Login Now",
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
      ),
    );
  }
}
