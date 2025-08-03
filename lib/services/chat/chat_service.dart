import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatbot/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  // get instance of firestore & auth & storage & supabase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final supabase = Supabase.instance.client;

  // get user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual user
        final user = doc.data();

        // return user (now includes ID for better tracking)
        return {"id": doc.id, ...user};
      }).toList();
    });
  }

  // send messages
  Future<void> sendMessage(String recieverID, String message) async {
    // get current user info
    final String currentUserID = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    MessageModel newMessage = MessageModel(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      recieverID: recieverID,
      message: message,
      timeStamp: timestamp,
      type: 'text',
    );

    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, recieverID];
    ids.sort(); // sort the ids (this ensures the chatroomID is the same for any 2 people)
    String chatRoomId = ids.join('_');

    // add new message to database
    await firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    // construct a chatroomID for the 2 users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // return messages ordered by timestamp
    return firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timeStamp", descending: false)
        .snapshots();
  }

  //get last message
  Stream<QuerySnapshot> getLastMessage(String chatRoomID) {
    return firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timeStamp", descending: true)
        .limit(1)
        .snapshots();
  }

  //upload to supabase
  Future<String> uploadFileToSupabase(File file) async {
    final now = DateTime.now();
    final formattedName =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';

    final extension = file.path.split('.').last;
    final fileName = '$formattedName.$extension';

    final filePath = 'uploads/$fileName';

    await supabase.storage.from('chat-files').upload(filePath, file);

    return supabase.storage.from('chat-files').getPublicUrl(filePath);
  }

  //send document to supabase
  Future<void> sendDocumentToSupabase(String recieverID) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String url = await uploadFileToSupabase(file);
      await sendFileMessage(recieverID, url, 'document');
    }
  }

  //send video to supabase
  Future<void> sendVideoToSupabase(String receiverID) async {
    final pickedVideo = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );

    if (pickedVideo != null) {
      File video = File(pickedVideo.path);
      String url = await uploadFileToSupabase(video);
      await sendFileMessage(receiverID, url, 'video');
    }
  }

  // Common function for sending file messages
  Future<void> sendFileMessage(
    String receiverID,
    String fileUrl,
    String type,
  ) async {
    final String currentUserID = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    MessageModel newMessage = MessageModel(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      recieverID: receiverID,
      fileUrl: fileUrl,
      type: type,
      timeStamp: timestamp,
    );

    await sendToFirestore(newMessage, receiverID);
  }

  // Save message in Firestore
  Future<void> sendToFirestore(MessageModel message, String receiverID) async {
    List<String> ids = [auth.currentUser!.uid, receiverID];
    ids.sort();
    String chatRoomId = ids.join('_');

    await firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(message.toMap());
  }

  //Related to Firestore Unused Code
  //issue - firebase storage was not available to the india region
  //upload file to firebase storage
  Future<String> uploadFileToFirebase(File file, String folder) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = storage.ref().child('$folder/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // Send document to firebase storage
  Future<void> sendDocumentToFirebase(String recieverID) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      String url = await uploadFileToFirebase(file, 'documents');
      final String currentUserID = auth.currentUser!.uid;
      final String currentUserEmail = auth.currentUser!.email!;
      final Timestamp timestamp = Timestamp.now();

      MessageModel newMessage = MessageModel(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        recieverID: recieverID,
        fileUrl: url,
        type: 'document',
        timeStamp: timestamp,
      );

      await sendtoFirestorePrivate(newMessage, recieverID);
    }
  }

  // Send video to firebase storage
  Future<void> sendVideoToFirebase(String recieverID) async {
    final pickedVideo = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedVideo != null) {
      File video = File(pickedVideo.path);
      String url = await uploadFileToFirebase(video, 'videos');
      final String currentUserID = auth.currentUser!.uid;
      final String currentUserEmail = auth.currentUser!.email!;
      final Timestamp timestamp = Timestamp.now();

      MessageModel newMessage = MessageModel(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        recieverID: recieverID,
        fileUrl: url,
        type: 'video',
        timeStamp: timestamp,
      );

      await sendtoFirestorePrivate(newMessage, recieverID);
    }
  }

  // Private function to add message to Firestore
  Future<void> sendtoFirestorePrivate(
    MessageModel message,
    String recieverID,
  ) async {
    List<String> ids = [auth.currentUser!.uid, recieverID];
    ids.sort();
    String chatRoomId = ids.join('_');

    await firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(message.toMap());
  }
}
