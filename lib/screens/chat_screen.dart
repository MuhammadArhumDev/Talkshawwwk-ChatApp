// 🟢 Full Updated ChatScreen with WhatsApp-style Reply Feature

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/models/contact_model.dart';
import 'package:whatsapp/utils/utils.dart';
import '../widgets/widgets.dart';

class MessageModel {
  final String senderId;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final bool isRead;
  final bool isDelivered;
  final String? reaction;
  final String? replyTo;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.isDelivered = true,
    this.reaction,
    this.replyTo,
  });

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'receiverId': receiverId,
    'message': message,
    'timestamp': timestamp,
    'isRead': isRead,
    'isDelivered': isDelivered,
    'reaction': reaction,
    'replyTo': replyTo,
  };

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      message: map['message'],
      timestamp: map['timestamp'],
      isRead: map['isRead'] ?? false,
      isDelivered: map['isDelivered'] ?? true,
      reaction: map['reaction'],
      replyTo: map['replyTo'],
    );
  }
}

class ChatScreen extends StatefulWidget {
  static const String id = 'chatscreen';
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isTyping = false;
  MessageModel? _replyingTo;

  late final ContactModel contact;
  late final String chatId;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ContactModel && user != null) {
      contact = args;
      chatId = getChatId(user!.uid, contact.uid);
    } else {
      showSnackBar(context, 'Error: Failed to open chat.');
      Navigator.pop(context);
    }
  }

  String getChatId(String uid1, String uid2) {
    return (uid1.compareTo(uid2) < 0) ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  void _onTextChanged(String value) {
    setState(() {
      isTyping = value.trim().isNotEmpty;
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      isTyping = false;
    });

    final msg = MessageModel(
      senderId: user!.uid,
      receiverId: contact.uid,
      message: text,
      timestamp: Timestamp.now(),
      replyTo: _replyingTo?.message,
    );

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(msg.toMap());

    setState(() => _replyingTo = null);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            decoration: const BoxDecoration(color: AppColors.black),
            child: Column(
              children: [
                // Header
                Container(
                  height: 58,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 7,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 0),
                      CachedNetworkImage(
                        imageUrl: contact.profilePicture ?? '',
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => CircleAvatar(
                          backgroundColor: AppColors.lightGrey,
                          child: Image.asset(
                            'assets/images/profileOne.png',
                            width: 80,
                            height: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          KWidgetText(
                            text: contact.fullName ?? 'Unknown',
                            size: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          KWidgetText(
                            text: 'last seen today at 3:22 PM',
                            size: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/ic_add_call.webp',
                            width: 27,
                            height: 27,
                          ),
                          const SizedBox(width: 10),
                          SvgPicture.asset(
                            'assets/images/menu.svg',
                            width: 27,
                            height: 27,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chat area
                Expanded(
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/backgroundTexture.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.8),
                        colorBlendMode: BlendMode.srcATop,
                      ),
                      MessageList(
                        chatId: chatId,
                        currentUserId: user!.uid,
                        onReply: (msg) => setState(() => _replyingTo = msg),
                      ),
                    ],
                  ),
                ),

                if (_replyingTo != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              KWidgetText(
                                text: _replyingTo!.senderId == user!.uid
                                    ? 'You'
                                    : contact.fullName ?? '',
                                size: 13,
                                color: AppColors.lightGrey,
                                fontWeight: FontWeight.w600,
                              ),
                              KWidgetText(
                                text: _replyingTo!.message,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() => _replyingTo = null),
                        ),
                      ],
                    ),
                  ),

                // Input Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkGrey,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  onChanged: _onTextChanged,
                                  minLines: 1,
                                  maxLines: 3,
                                  keyboardType: TextInputType.multiline,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  style: GoogleFonts.manrope(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Type a message',
                                    hintStyle: GoogleFonts.manrope(
                                      color: AppColors.lightGrey,
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: isTyping ? _sendMessage : null,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.brightGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.black,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MessageList extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final Function(MessageModel) onReply;

  const MessageList({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.onReply,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  late List<MessageModel> _messages = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        _messages = snapshot.data!.docs
            .map(
              (doc) => MessageModel.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList();

        return ListView.builder(
          reverse: true,
          itemCount: _messages.length,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          itemBuilder: (context, index) {
            final msg = _messages[index];
            final isMe = msg.senderId == widget.currentUserId;

            return SwipeToReplyMessage(
              message: msg,
              isMe: isMe,
              onReply: () => widget.onReply(msg),
            );
          },
        );
      },
    );
  }
}

class SwipeToReplyMessage extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback onReply;

  const SwipeToReplyMessage({
    super.key,
    required this.message,
    required this.isMe,
    required this.onReply,
  });

  @override
  State<SwipeToReplyMessage> createState() => _SwipeToReplyMessageState();
}

class _SwipeToReplyMessageState extends State<SwipeToReplyMessage>
    with SingleTickerProviderStateMixin {
  double dx = 0.0;
  bool showReplyIcon = false;
  static const maxSwipe = 100.0;

  void _handleSwipeUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 0) {
      setState(() {
        dx += details.delta.dx;
        dx = min(dx, maxSwipe);
        showReplyIcon = dx > 60;
      });
    }
  }

  void _handleSwipeEnd(DragEndDetails details) {
    if (showReplyIcon) {
      widget.onReply();
    }

    setState(() {
      dx = 0;
      showReplyIcon = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleSwipeUpdate,
      onHorizontalDragEnd: _handleSwipeEnd,
      child: Stack(
        children: [
          // Background reply icon
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: showReplyIcon ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: const Icon(Icons.reply, color: Colors.white70, size: 24),
              ),
            ),
          ),

          // Actual message card
          Transform.translate(
            offset: Offset(dx, 0),
            child: Align(
              alignment: widget.isMe
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isMe
                        ? AppColors.darkGreen
                        : AppColors.darkGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: widget.isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (widget.message.replyTo != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isMe
                                ? AppColors.replyPane
                                : AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: KWidgetText(
                            text: widget.message.replyTo!,
                            size: 14,
                            color: widget.isMe
                                ? AppColors.lightGrey
                                : AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      KWidgetText(
                        text: widget.message.message,
                        color: widget.isMe
                            ? AppColors.brightGreen
                            : AppColors.white,
                        size: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      if (widget.message.reaction != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            widget.message.reaction!,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: widget.isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          KWidgetText(
                            text: formatTimestamp(widget.message.timestamp),
                            color: AppColors.lightGrey,
                            size: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          if (widget.isMe) const SizedBox(width: 5),
                          if (widget.isMe)
                            Icon(
                              Icons.done_all,
                              size: 16,
                              color: widget.message.isRead
                                  ? Colors.blue
                                  : AppColors.lightGrey,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String formatTimestamp(Timestamp timestamp) {
  final date = timestamp.toDate();
  final hour = date.hour > 12 ? date.hour - 12 : date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}
