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
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Chat",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: "App",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       logout();
        //     },
        //     icon: Icon(Icons.logout),
        //   ),
        // ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,

          children: [
            // Drawer Header with Profile
            UserAccountsDrawerHeader(
              accountName: Text(
                chatService.auth.currentUser!.email!.split('@')[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                chatService.auth.currentUser!.email!,
                style: const TextStyle(fontSize: 14),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.blue),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            // Home Button
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Home
              },
            ),

            // Profile Button
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Profile
              },
            ),

            Divider(),

            // Logout Button
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context); // Close drawer
                logout(); // Call logout function
              },
            ),
          ],
        ),
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
        name: userData["email"].split('@')[0], 
        lastMessage:
            "Hey! How are you?", 
        time: "5:30 AM",
        unreadCount: 2,
        isOnline: true,
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
