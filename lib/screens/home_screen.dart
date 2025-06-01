import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/models/contact_model.dart';
import 'package:whatsapp/screens/adduser_screen.dart';
import 'package:whatsapp/screens/chat_screen.dart';
import 'package:whatsapp/screens/login_screen.dart';
import 'package:whatsapp/screens/popup_screen.dart';
import 'package:whatsapp/utils/utils.dart';
import 'package:whatsapp/widgets/contact_tile_widget.dart';
import 'package:whatsapp/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'homescreen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> tabs = [
    'All',
    'Unread',
    'Favourites',
    'Groups',
    'Friends',
    'Family',
  ];

  int selectedTopTabIndex = 0;
  int selectedBottomTabIndex = 0;

  Stream<List<ContactModel>> getChatContacts() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance.collection('chats').snapshots().asyncMap((
      snapshot,
    ) async {
      final List<ContactModel> contactList = [];

      for (final chatDoc in snapshot.docs) {
        final chatId = chatDoc.id;

        final parts = chatId.split('_');
        if (parts.length != 2) continue;

        if (parts[0] != currentUserId && parts[1] != currentUserId) continue;

        // Get the other user
        final contactId = parts[0] == currentUserId ? parts[1] : parts[0];

        // Fetch the latest message
        final messagesQuery = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (messagesQuery.docs.isEmpty) continue;

        final latestMessageData = messagesQuery.docs.first.data();
        final senderId = latestMessageData['senderId'];
        final receiverId = latestMessageData['receiverId'];

        if (senderId != currentUserId && receiverId != currentUserId) continue;

        // Get other user's info
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(contactId)
            .get();
        if (!userDoc.exists) continue;

        final userData = userDoc.data()!;
        final latestMessage = latestMessageData['message'] ?? '';

        // Format timestamp
        final timestamp = latestMessageData['timestamp'] as Timestamp?;
        String time = '';
        if (timestamp != null) {
          final date = timestamp.toDate();
          time =
              '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        }

        // Get unread count (messages sent TO user that are unread)
        final unreadQuery = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('isRead', isEqualTo: false)
            .where('senderId', isNotEqualTo: currentUserId)
            .get();

        final unreadCount = unreadQuery.docs.length;

        // Create contact model
        contactList.add(
          ContactModel.fromMap({
            ...userData,
            'uid': contactId,
            'message': latestMessage,
            'time': time,
            'unreadCount': unreadCount,
          }),
        );
      }

      return contactList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.black,
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.brightGreen,
          onPressed: () {
            Navigator.pushNamed(context, AdduserScreen.id);
          },
          shape: const CircleBorder(),
          child: SvgPicture.asset(
            'assets/images/new_chat.svg',
            width: 35,
            height: 35,
            fit: BoxFit.contain,
          ),
        ),
        bottomNavigationBar: Container(
          height: 75,
          decoration: const BoxDecoration(
            color: AppColors.black,
            border: Border(
              top: BorderSide(color: AppColors.darkGrey, width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < 4; i++)
                GestureDetector(
                  onTap: () => setState(() => selectedBottomTabIndex = i),
                  child: _buildNavItem(
                    filledIconPath:
                        'assets/images/ic_home_tab_${['chats', 'updates', 'communities', 'calls'][i]}_filled.webp',
                    unfilledIconPath:
                        'assets/images/ic_home_tab_${['chats', 'updates', 'communities', 'calls'][i]}_unfilled.webp',
                    label: ['Chats', 'Updates', 'Communities', 'Calls'][i],
                    isActive: selectedBottomTabIndex == i,
                  ),
                ),
            ],
          ),
        ),
        body: _getBodyForTab(),
      ),
    );
  }

  Widget _getBodyForTab() {
    if (selectedBottomTabIndex != 0) {
      return Center(
        child: KWidgetText(
          text:
              '${['Chats', 'Status', 'Communities', 'Calls'][selectedBottomTabIndex]} screen coming soon!',
          color: AppColors.lightGrey,
          size: 18,
        ),
      );
    }

    return Container(
      color: AppColors.black,
      child: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                KWidgetText(
                  text: 'Talkshawwwk',
                  color: Colors.white,
                  size: 30,
                  fontWeight: FontWeight.bold,
                ),
                PopupMenuButton<String>(
                  icon: SvgPicture.asset(
                    'assets/images/menu.svg',
                    width: 30,
                    height: 30,
                    color: Colors.white,
                  ),
                  offset: const Offset(0, 40),
                  color: AppColors.darkGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onSelected: (value) async {
                    if (value == 'New Group') {
                      showSnackBar(context, 'New Group tapped');
                    } else if (value == 'Settings') {
                      Navigator.pushNamed(context, CustomPopupExample.id);
                    } else if (value == 'Logout') {
                      try {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          LoginScreen.id,
                          (route) => false,
                        );
                      } catch (e) {
                        showSnackBar(
                          context,
                          'Logout failed. Please try again.',
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    _buildMenuItem('New Group'),
                    _buildMenuItem('Settings'),
                    PopupMenuItem<String>(
                      value: 'Logout',
                      child: Text(
                        'Logout',
                        style: GoogleFonts.manrope(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: KWidgetTextField(
              hintText: 'Search anything',
              keyboardType: TextInputType.text,
              obscureText: false,
              maxLines: 1,
              controller: TextEditingController(),
              textStyle: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              validator: null,
              prefixIcon: const Icon(Icons.search, color: AppColors.lightGreen),
              fillColor: AppColors.darkGrey,
              borderColor: AppColors.black,
              borderRadius: 50.0,
              focusedBorderColor: AppColors.lightGreen,
              errorBorderColor: Colors.red,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabled: true,
              hintStyle: const TextStyle(color: AppColors.lightGrey),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedTopTabIndex;
                return GestureDetector(
                  onTap: () => setState(() => selectedTopTabIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.darkGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color.fromARGB(50, 134, 138, 141),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tabs[index],
                        style: GoogleFonts.manrope(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.lightGrey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<ContactModel>>(
              stream: getChatContacts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: KWidgetText(
                      text: 'No chats yet',
                      color: AppColors.lightGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                final contacts = snapshot.data!;
                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) =>
                      ContactTile(contact: contacts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(
        value,
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String filledIconPath,
    required String unfilledIconPath,
    required String label,
    required bool isActive,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 35,
          height: 35,
          child: Image.asset(
            isActive ? filledIconPath : unfilledIconPath,
            fit: BoxFit.contain,
            color: isActive ? AppColors.brightGreen : AppColors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.brightGreen : AppColors.white,
          ),
        ),
      ],
    );
  }
}
