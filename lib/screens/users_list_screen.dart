import 'package:chatbot/screens/pages/user_profile_page.dart';
import 'package:chatbot/services/auth/auth_service.dart';
import 'package:chatbot/services/chat/chat_service.dart';
import 'package:chatbot/components/custom_usertile.dart';
import 'package:chatbot/screens/pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersListScreen extends StatelessWidget {
  UsersListScreen({super.key});

  //get instance of auth & chat
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  //formatted time to last time message
  String _formatTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  //logout
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
      ),
      drawer: Drawer(
        child: StreamBuilder(
          stream: chatService.getUserStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Get current user data
            final currentUserData = snapshot.data!.firstWhere(
              (user) => user["email"] == authService.getCurrentUser()!.email,
              orElse: () => {},
            );

            return Column(
              children: [
                // Drawer Header
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage(userData: currentUserData),
                      ),
                    );
                  },
                  child: UserAccountsDrawerHeader(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      border: Border(bottom: BorderSide.none),
                    ),
                    accountName: Text(
                      currentUserData["name"] ??
                          currentUserData["email"].split('@')[0],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    accountEmail: Text(
                      currentUserData["email"],
                      style: const TextStyle(fontSize: 14),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage:
                          (currentUserData['profilePicUrl'] != null &&
                              currentUserData['profilePicUrl'].isNotEmpty)
                          ? NetworkImage(currentUserData['profilePicUrl'])
                          : null,
                      backgroundColor: Colors.white,
                      child:
                          (currentUserData['profilePicUrl'] == null ||
                              currentUserData['profilePicUrl'].isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.blue,
                            )
                          : null,
                    ),
                  ),
                ),

                // Menu items in Expanded
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text(
                          'Home',
                          style: TextStyle(letterSpacing: 2),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text(
                          'Profile',
                          style: TextStyle(letterSpacing: 2),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserProfilePage(userData: currentUserData),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Logout button
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red, letterSpacing: 2),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    logout();
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: chatService.getUserStream(),
      builder: (context, snapshot) {
        // Handle errors
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        // Show loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle empty state
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No users available 👤",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }

        // Build user list
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    final currentUserID = authService.getCurrentUser()!.uid;
    final otherUserID = userData["uid"];
    final chatRoomID = [currentUserID, otherUserID]..sort();
    final chatRoomPath = chatRoomID.join('_');

    if (userData["email"] == authService.getCurrentUser()!.email) {
      return Container();
    }

    return StreamBuilder(
      stream: chatService.getLastMessage(chatRoomPath),
      builder: (context, snapshot) {
        String lastMessage = "Say hi!";
        String time = "";
        int unreadCount = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final doc = snapshot.data!.docs.first;
          lastMessage =
              doc['message'] ??
              (doc['type'] == 'video' ? "🎥 Video" : "📄 Document");
          time = _formatTime(doc['timeStamp']);
        }

        return CustomUsertile(
          name: userData["email"].split('@')[0],
          lastMessage: lastMessage,
          time: time,
          unreadCount: unreadCount,
          isOnline: userData['isOnline'] ?? false,
          profilePicUrl: userData['profilePicUrl'] ?? '',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  recieverEmail: userData["email"],
                  recieverID: otherUserID,
                ),
              ),
            );
          },
          onProfileTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(userData: userData),
              ),
            );
          },
        );
      },
    );
  }
}
