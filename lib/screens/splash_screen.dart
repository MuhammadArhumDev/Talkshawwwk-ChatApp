import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/utils/constants.dart';
import 'package:whatsapp/widgets/widgets.dart';
import 'screens.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splashscreen';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    // Optional: Wait a tiny bit to let splash show for very short time
    await Future.delayed(const Duration(milliseconds: 500));

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      // User is logged in
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    } else {
      // Not logged in
      Navigator.pushReplacementNamed(context, LoginScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.black, elevation: 0),
      bottomNavigationBar: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.only(bottom: 30),
          width: double.infinity,
          color: AppColors.black,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KWidgetText(text: 'from', color: AppColors.lightGrey, size: 16),
                const SizedBox(width: 5),
                KWidgetText(
                  text: 'Devzey',
                  color: AppColors.brightGreen,
                  size: 16,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.black,
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
            ],
          ),
        ),
      ),
    );
  }
}
