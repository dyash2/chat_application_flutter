import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String recieverEmail;
  const ChatScreen({super.key, required this.recieverEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(recieverEmail)));
  }
}
