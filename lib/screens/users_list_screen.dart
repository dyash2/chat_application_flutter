import 'package:chatbot/services/auth/auth_service.dart';
import 'package:chatbot/services/chat/chat_service.dart';
import 'package:chatbot/components/custom_usertile.dart';
import 'package:chatbot/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class UsersListScreen extends StatelessWidget {
  UsersListScreen({super.key});

  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  void logout() {
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [FlutterLogo(size: 50), Text("ChatApp")]),
        actions: [
          IconButton(
            onPressed: () {
              logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: chatService.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading...");
        }
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // build individual list tile for user
  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    if (userData["email"] != authService.getCurrentUser()!.email) {
      // display all users except current user
      return CustomUsertile(
        text: userData["email"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                recieverEmail: userData["email"],
                recieverID: userData["uid"],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
