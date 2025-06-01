import 'package:flutter/material.dart';
import 'package:whatsapp/screens/popup_screen.dart';
import 'package:whatsapp/screens/screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        RegisterScreen.id: (context) => const RegisterScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        ChatScreen.id: (context) => const ChatScreen(),
        CustomPopupExample.id: (context) => const CustomPopupExample(),
        AdduserScreen.id: (context) => const AdduserScreen(),
      },
    );
  }
}
