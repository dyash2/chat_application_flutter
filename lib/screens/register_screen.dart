import 'package:chatbot/components/custom_button.dart';
import 'package:chatbot/components/custom_textfield.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailCtrller = TextEditingController();
  final TextEditingController pwCtrller = TextEditingController();
  final TextEditingController confirmpwCtrller = TextEditingController();
  final void Function()? onTap;
  RegisterScreen({super.key, required this.onTap});

  void register() {
    // login logic
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //App Logo
            const FlutterLogo(size: 80),

            const SizedBox(height: 24),

            // Create an account Message
            const Text(
              "Let's create a account for you",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 32),

            // Email TextField
            CustomTextfield(label: "Email", controller: emailCtrller),

            const SizedBox(height: 16),

            //Password TextField
            CustomTextfield(label: "Password", controller: pwCtrller),
            const SizedBox(height: 16),

            // Confirm Password TextField
            CustomTextfield(
              label: "Confirm Password",
              controller: confirmpwCtrller,
            ),

            const SizedBox(height: 24),

            // Register Button
            CustomButton(
              text: "Register",
              onPressed: () {
                register();
              },
            ),

            const SizedBox(height: 24),

            // Login Text with GestureDetector
            Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account!"),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Login Now",
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
    );
  }
}
