import 'package:chatbot/components/custom_textfield.dart';
import 'package:chatbot/services/auth/auth_service.dart';
import 'package:chatbot/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatelessWidget {
  final String recieverEmail;
  final String recieverID;

  ChatScreen({
    super.key,
    required this.recieverEmail,
    required this.recieverID,
  });

  // text controller
  final TextEditingController messageController = TextEditingController();

  // chat & auth services
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  // send message
  void sendMessage() async {
    // if there is something inside the textfield
    if (messageController.text.isNotEmpty) {
      // send the message
      await chatService.sendMessage(recieverID, messageController.text);

      // clear the text
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = recieverEmail.split('@')[0];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          displayName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Go Back
          },
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // display all messages
          Expanded(child: buildMessageList()),

          // user input
          buildUserInput(),
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
        // errors
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading messages"));
        }
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // return ListView
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) =>
              buildMessageItem(snapshot.data!.docs[index]),
        );
      },
    );
  }

  Widget buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data["senderID"] == authService.getCurrentUser()!.uid;

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
        onTap: () {
          // Open document in browser
          launchUrl(Uri.parse(data['fileUrl']));
        },
        child: Text(
          "📄 Document",
          style: TextStyle(
            color: isCurrentUser ? Colors.white : Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (data['type'] == 'video') {
      messageContent = GestureDetector(
        onTap: () {
          // Open video in browser
          launchUrl(Uri.parse(data['fileUrl']));
        },
        child: Text(
          "🎥 Video",
          style: TextStyle(
            color: isCurrentUser ? Colors.white : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          color: isCurrentUser ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: messageContent,
      ),
    );
  }

  // build message input
  Widget buildUserInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Pick document
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.blueAccent),
            onPressed: () => chatService.sendDocument(recieverID),
          ),

          // Pick video
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.blueAccent),
            onPressed: () => chatService.sendVideo(recieverID),
          ),

          // textfield
          Expanded(
            child: CustomTextfield(
              label: "Type a message",
              controller: messageController,
            ),
          ),

          const SizedBox(width: 8),

          // send button
          Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
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
