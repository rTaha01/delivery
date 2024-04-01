import 'dart:async';
import 'package:delivery_app/screens/home/main_page.dart';
import 'package:delivery_app/utlis/color_codes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../auth/chooseNumber.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

void checkUser(context) {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final user = firebaseAuth.currentUser;
  if (user != null) {
    Timer(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    });
    print("user found");
  } else {
    Timer(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ChooseNumber()),
        (route) => false,
      );
    });
    print("user not found");

  }
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
                opacity: 0.3,
                child: Image.asset(
                  "assets/images/splash_bg.png",
                  fit: BoxFit.fill,
                  height: 700.h,
                  width: double.infinity,
                )),
            Center(
              child: Image.asset(
                'assets/images/splash_logo.png',
                width: 300,
                height: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
