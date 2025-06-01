import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/screens/login_screen.dart';
import 'package:whatsapp/utils/utils.dart';
import 'package:whatsapp/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens.dart';

class RegisterScreen extends StatefulWidget {
  static final String id = 'registerscreen';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(color: AppColors.black),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.darkGreen,
                        child: SvgPicture.asset(
                          'assets/images/logoOne.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    KWidgetText(
                      text: 'TalkShawwwk',
                      size: 33,
                      color: AppColors.brightGreen,
                      fontWeight: FontWeight.bold,
                    ),
                    KWidgetText(
                      text: 'Sign up to continue',
                      size: 16,
                      color: AppColors.lightGrey,
                    ),
                    const SizedBox(height: 30),

                    // Name
                    buildField(
                      controller: _nameController,
                      hint: 'Enter your full name',
                      icon: Icons.person,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Name required' : null,
                    ),

                    // Username
                    buildField(
                      controller: _usernameController,
                      hint: 'Choose a username',
                      icon: Icons.alternate_email,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Username required'
                          : null,
                    ),

                    // Email
                    buildField(
                      controller: _emailController,
                      hint: 'Enter your email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val == null || !val.contains('@')
                          ? 'Enter valid email'
                          : null,
                    ),

                    // Password
                    buildField(
                      controller: _passwordController,
                      hint: 'Enter your password',
                      icon: Icons.lock,
                      obscureText: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.lightGrey,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      validator: (val) => val == null || val.length < 6
                          ? 'Minimum 6 characters'
                          : null,
                    ),

                    // Confirm Password
                    buildField(
                      controller: _confirmPasswordController,
                      hint: 'Confirm your password',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.lightGrey,
                        ),
                        onPressed: () {
                          setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          );
                        },
                      ),
                      validator: (val) => val != _passwordController.text
                          ? 'Passwords do not match'
                          : null,
                    ),

                    const SizedBox(height: 40),

                    // Register Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brightGreen,
                            foregroundColor: AppColors.darkGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _registerUser,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.darkGreen,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Register',
                                  style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        KWidgetText(
                          text: 'Already have an account?',
                          color: AppColors.lightGrey,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, LoginScreen.id),
                          child: KWidgetText(
                            text: 'Login',
                            color: AppColors.brightGreen,
                            size: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final usernameLower = username.toLowerCase();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.length < 6 ||
        password != confirmPassword) {
      showSnackBar(context, 'Please fill all fields correctly');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔍 Check if username exists (case-insensitive)
      final existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('username_lowercase', isEqualTo: usernameLower)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        setState(() => _isLoading = false);
        showSnackBar(context, 'Username already in use');
        return;
      }

      // ✅ Create user with Firebase Auth
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final String uid = userCredential.user!.uid;

      // ✅ Store user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': name,
        'username': username,
        'username_lowercase':
            usernameLower, // Required for case-insensitive search
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'profilePicture': '',
        'uid': uid,
        'status': 'Hey there! I am using TalkShawwwk',
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);

      // 🔁 Navigate to login screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.id,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (e.code == 'email-already-in-use') {
        showSnackBar(context, 'Email already in use');
      } else {
        showSnackBar(context, e.message ?? 'Registration failed');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showSnackBar(context, 'Something went wrong. Try again.');
    }
  }
}
