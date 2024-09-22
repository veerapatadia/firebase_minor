import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  User? user;

  void checkAuthStatus() {
    user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);

    animation = Tween<double>(begin: 0, end: -50).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    timer = Timer(
      Duration(seconds: 3),
      () {
        FirebaseAuth.instance.currentUser != null
            ? Navigator.of(context).pushReplacementNamed("/")
            : Navigator.of(context).pushReplacementNamed("login_page1");
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment(0, 0.85),
        children: [
          Center(
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, animation.value), // Bounce effect
                  child: Image.asset(
                    "assets/chat-icon.png",
                    height: 135,
                  ),
                );
              },
            ),
          ),
          Text(
            "Chat App",
            style: TextStyle(
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
