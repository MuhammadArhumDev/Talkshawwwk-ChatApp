import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';
import 'widgets.dart';

// // 👇 MessageList widget to prevent unnecessary rebuilds
// class MessageList extends StatelessWidget {
//   final String chatId;
//   final String currentUserId;

//   const MessageList({
//     Key? key,
//     required this.chatId,
//     required this.currentUserId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('chats')
//           .doc(chatId)
//           .collection('messages')
//           .orderBy('timestamp', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final messages = snapshot.data!.docs;

//         return ListView.builder(
//           reverse: true,
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           itemCount: messages.length,
//           itemBuilder: (context, index) {
//             final msg = messages[index].data() as Map<String, dynamic>;
//             final isMe = msg['senderId'] == currentUserId;

//             return Align(
//               alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   maxWidth: MediaQuery.of(context).size.width * 0.7,
//                 ),
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(vertical: 3),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 7,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isMe ? AppColors.darkGreen : AppColors.darkGrey,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: isMe
//                         ? CrossAxisAlignment.end
//                         : CrossAxisAlignment.start,
//                     children: [
//                       // Message Text
//                       KWidgetText(
//                         text: msg['message'] ?? '',
//                         color: isMe ? AppColors.brightGreen : AppColors.white,
//                         size: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       const SizedBox(height: 4),

//                       // Timestamp & Ticks
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: isMe
//                             ? MainAxisAlignment.end
//                             : MainAxisAlignment.start,
//                         children: [
//                           KWidgetText(
//                             text: formatTimestamp(msg['timestamp']),
//                             color: AppColors.lightGrey,
//                             size: 11,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           if (isMe) const SizedBox(width: 5),
//                           if (isMe)
//                             Icon(
//                               getTickIcon(msg),
//                               size: 16,
//                               color: msg['isRead'] == true
//                                   ? Colors.blue
//                                   : AppColors.lightGrey,
//                             ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//             ;
//           },
//         );
//       },
//     );
//   }
// }

// String formatTimestamp(dynamic timestamp) {
//   if (timestamp == null) return '';
//   final date = (timestamp as Timestamp).toDate();
//   final hour = date.hour > 12 ? date.hour - 12 : date.hour;
//   final minute = date.minute.toString().padLeft(2, '0');
//   final suffix = date.hour >= 12 ? 'PM' : 'AM';
//   return '$hour:$minute $suffix';
// }

// IconData getTickIcon(Map<String, dynamic> msg) {
//   // For this example, we only simulate sent vs read
//   if (msg['isRead'] == true) return Icons.done_all; // blue double tick
//   return Icons.done_all; // grey double tick (sent/delivered)
// }
