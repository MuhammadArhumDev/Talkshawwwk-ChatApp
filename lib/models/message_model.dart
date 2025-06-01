import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String? id;
  final String message;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;
  final bool isRead;
  final bool isDelivered;
  final String? reaction;
  final String messageType; // text, image, audio, video, etc.
  final String? mediaUrl;
  final String? replyTo;
  final List<String>? deletedFor;
  final bool deletedForEveryone;

  MessageModel({
    this.id,
    required this.message,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    this.isRead = false,
    this.isDelivered = false,
    this.reaction,
    this.messageType = 'text',
    this.mediaUrl,
    this.replyTo,
    this.deletedFor,
    this.deletedForEveryone = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String? id) {
    return MessageModel(
      id: id,
      message: map['message'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      isDelivered: map['isDelivered'] ?? false,
      reaction: map['reaction'],
      messageType: map['messageType'] ?? 'text',
      mediaUrl: map['mediaUrl'],
      replyTo: map['replyTo'],
      deletedFor: List<String>.from(map['deletedFor'] ?? []),
      deletedForEveryone: map['deletedForEveryone'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'isRead': isRead,
      'isDelivered': isDelivered,
      'reaction': reaction,
      'messageType': messageType,
      'mediaUrl': mediaUrl,
      'replyTo': replyTo,
      'deletedFor': deletedFor ?? [],
      'deletedForEveryone': deletedForEveryone,
    };
  }
}
