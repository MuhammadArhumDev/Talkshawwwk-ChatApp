import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/models/contact_model.dart';
import 'package:whatsapp/screens/chat_screen.dart';
import 'package:whatsapp/screens/home_screen.dart';
import 'package:whatsapp/utils/utils.dart';
import 'package:whatsapp/widgets/widgets.dart';

class AdduserScreen extends StatefulWidget {
  static const String id = 'adduserscreen';
  const AdduserScreen({super.key});

  @override
  State<AdduserScreen> createState() => _AdduserScreenState();
}

class _AdduserScreenState extends State<AdduserScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool isLoading = false;
  Map<String, dynamic>? User;

  @override
  void initState() {
    super.initState();

    // Clear card when typing
    _usernameController.addListener(() {
      if (_usernameController.text.isEmpty && User != null) {
        setState(() {
          User = null;
        });
      }
    });
  }

  Future<void> _searchUser() async {
    final username = _usernameController.text.trim().toLowerCase();
    if (username.isEmpty) {
      showSnackBar(context, 'Username is required');
      return;
    }

    setState(() {
      isLoading = true;
      User = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username_lowercase', isEqualTo: username)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          User = null;
        });
      } else {
        setState(() {
          User = snapshot.docs.first.data();
        });
      }
    } catch (e) {
      showSnackBar(context, 'Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _goToChat() {
    if (User != null) {
      Navigator.pushReplacementNamed(
        context,
        ChatScreen.id,
        arguments: ContactModel.fromMap(User!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              KWidgetText(
                text: 'Add New Contact',
                color: AppColors.brightGreen,
                size: 23,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              KWidgetText(
                textAlign: TextAlign.center,
                text:
                    'Ask the user for his/her unique username and then search here to text and add them as a contact.',
                color: AppColors.lightGrey,
                size: 16,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 30),
              buildField(
                controller: _usernameController,
                hint: 'Search username',
                icon: Icons.alternate_email,
                validator: (_) => null,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: KWidgetButton(
                  text: isLoading ? 'Searching...' : 'Search Users',
                  onPressed: isLoading ? null : _searchUser,
                  backgroundColor: AppColors.brightGreen,
                  textColor: AppColors.darkGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 1,
                color: AppColors.darkGrey,
              ),
              const SizedBox(height: 40),

              // No user found
              if (!isLoading &&
                  User == null &&
                  _usernameController.text.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.darkGrey,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      KWidgetText(
                        text: 'No users found',
                        color: AppColors.brightGreen,
                        size: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 10),
                      KWidgetText(
                        textAlign: TextAlign.center,
                        text:
                            'Try searching with a different username or ask the user to register first.',
                        color: AppColors.lightGrey,
                        size: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                )
              // User found
              else if (User != null)
                GestureDetector(
                  onTap: _goToChat,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: User!["profilePicture"].isNotEmpty
                              ? NetworkImage(User!["profilePicture"])
                              : null,
                          child: User!["profilePicture"].isEmpty
                              ? Icon(Icons.person, color: Colors.white)
                              : null,
                          backgroundColor: AppColors.lightGrey,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              KWidgetText(
                                text: User!["fullName"] ?? "No Name",
                                color: AppColors.brightGreen,
                                size: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              KWidgetText(
                                text: "@${User!["username"]}",
                                color: AppColors.lightGrey,
                                size: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.message,
                          color: AppColors.brightGreen,
                          size: 26,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
