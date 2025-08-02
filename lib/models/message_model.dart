import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderID;
  final String senderEmail;
  final String recieverID;
  final String? message;
  final Timestamp timeStamp;
  final String? fileUrl;
  final String type;

  MessageModel({
    required this.senderID,
    required this.senderEmail,
    required this.recieverID,
    this.message,
    required this.timeStamp,
    this.fileUrl,
    required this.type,
  });

  // convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'recieverID': recieverID,
      'message': message,
      'timeStamp': timeStamp,
      'fileUrl': fileUrl,
      'type': type,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderID: map['senderID'],
      senderEmail: map['senderEmail'],
      recieverID: map['recieverID'],
      message: map['message'],
      timeStamp: map['timeStamp'],
      fileUrl: map['fileUrl'],
      type: map['type'],
    );
  }
}
