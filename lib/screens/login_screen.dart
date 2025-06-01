import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/screens/screens.dart';
import 'package:whatsapp/utils/utils.dart';
import 'package:whatsapp/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  static final String id = 'loginscreen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(color: AppColors.black),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                    text: 'Sign in to continue',
                    size: 16,
                    color: AppColors.lightGrey,
                  ),

                  const SizedBox(height: 30),

                  // Email Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: KWidgetTextField(
                      hintText: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                      maxLines: 1,
                      textStyle: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(
                        Icons.email,
                        color: AppColors.lightGreen,
                      ),
                      fillColor: AppColors.darkGrey,
                      borderColor: AppColors.lightGrey,
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

                  // Password Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: KWidgetTextField(
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _obscurePassword,
                      maxLines: 1,
                      textStyle: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: AppColors.lightGreen,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.lightGrey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      fillColor: AppColors.darkGrey,
                      borderColor: AppColors.lightGrey,
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

                  const SizedBox(height: 50),

                  // Login Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
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
                        onPressed: _isLoading ? null : _loginUser,
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
                                'Login',
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sign Up Redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      KWidgetText(
                        text: 'Don\'t have an account?',
                        color: AppColors.lightGrey,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, RegisterScreen.id);
                        },
                        child: KWidgetText(
                          text: 'Sign Up',
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
    );
  }

  Future<void> _loginUser() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showSnackBar(context, 'Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Login successful
      setState(() => _isLoading = false);

      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.id,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      showSnackBar(context, e.message ?? 'Login failed');
    } catch (e) {
      setState(() => _isLoading = false);
      showSnackBar(context, 'Something went wrong. Please try again.');
    }
  }
}
