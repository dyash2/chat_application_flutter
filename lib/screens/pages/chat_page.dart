import 'package:chatbot/screens/pages/user_profile_page.dart';
import 'package:chatbot/components/custom_textfield.dart';
import 'package:chatbot/services/auth/auth_service.dart';
import 'package:chatbot/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatelessWidget {
  final String recieverEmail;
  final String recieverID;

  ChatPage({super.key, required this.recieverEmail, required this.recieverID});

  // text controller
  final TextEditingController messageController = TextEditingController();

  // chat & auth services
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  // send text message
  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      await chatService.sendMessage(recieverID, messageController.text);
      messageController.clear();
    }
  }

  // safely launch URLs (documents/videos)
  Future<void> openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not open URL: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayName =
        recieverEmail.split('@')[0][0].toUpperCase() +
        recieverEmail.split('@')[0].substring(1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(recieverID)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text(
                recieverEmail.split('@')[0],
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final profilePicUrl = userData['profilePicUrl'] ?? '';

            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage(userData: userData),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: profilePicUrl.isNotEmpty
                        ? NetworkImage(profilePicUrl)
                        : null,
                    child: profilePicUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),

      body: Column(
        children: [
          Expanded(child: buildMessageList()),
          buildUserInput(context),
        ],
      ),
    );
  }

  // build message list
  Widget buildMessageList() {
    String senderID = authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: chatService.getMessages(senderID, recieverID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading messages"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) =>
              buildMessageItem(snapshot.data!.docs[index], context),
        );
      },
    );
  }

  // build message item
  Widget buildMessageItem(DocumentSnapshot doc, BuildContext context) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data["senderID"] == authService.getCurrentUser()!.uid;

    DateTime timestamp = (data['timeStamp'] as Timestamp).toDate();
    String formattedTime =
        "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";

    Widget messageContent;
    if (data['type'] == 'text') {
      messageContent = Text(
        data['message'],
        style: TextStyle(
          color: isCurrentUser ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
      );
    } else if (data['type'] == 'document') {
      messageContent = GestureDetector(
        onTap: () => launchUrl(Uri.parse(data['fileUrl'])),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, color: Colors.blueAccent),
            SizedBox(width: 6),
            Text(
              data['fileUrl'].split('/').last,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (data['type'] == 'video') {
      messageContent = GestureDetector(
        onTap: () => launchUrl(Uri.parse(data['fileUrl'])),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam, color: Colors.redAccent),
            SizedBox(width: 6),
            Text(
              "Watch Video",
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (data['type'] == 'image') {
      messageContent = Image.network(
        data['fileUrl'],
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      );
    } else {
      messageContent = const Text("Unsupported message");
    }

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            messageContent,
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 10,
                  color: isCurrentUser ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // build message input
  Widget buildUserInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.blueAccent),
            onPressed: () => chatService.sendDocumentToSupabase(recieverID),
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.blueAccent),
            onPressed: () => chatService.sendVideoToSupabase(recieverID),
          ),
          Expanded(
            child: CustomTextfield(
              label: "Type a message...",
              controller: messageController,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
