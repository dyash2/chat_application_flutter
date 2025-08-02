import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderID;
  final String senderEmail;
  final String recieverID;
  final String message;
  final Timestamp timeStamp;

  MessageModel({
    required this.senderID,
    required this.senderEmail,
    required this.recieverID,
    required this.message,
    required this.timeStamp,
  });

  // convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'recieverID': recieverID,
      'message': message,
      'timeStamp': timeStamp, // match exactly with Firestore query
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderID: map['senderID'],
      senderEmail: map['senderEmail'],
      recieverID: map['recieverID'],
      message: map['message'],
      timeStamp: map['timeStamp'],
    );
  }
}
