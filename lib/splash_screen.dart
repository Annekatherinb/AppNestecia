import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'carousel.dart';
import 'login.dart';

class SplashScreenApp extends StatefulWidget {
  final bool showOnboarding;
  const SplashScreenApp({super.key, required this.showOnboarding});

  @override
  State<SplashScreenApp> createState() => _SplashScreenAppState();
}

class _SplashScreenAppState extends State<SplashScreenApp> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: Image.asset('assets/images/hospital.png'),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/principalLOG.png', height: 100),
                const SizedBox(height: 20),
                const Text(
                  "Anestesia App",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      splashIconSize: 400,
      duration: 2500,
      backgroundColor: Colors.black,
      splashTransition: SplashTransition.scaleTransition,
      pageTransitionType: PageTransitionType.fade,

      nextScreen:const CarouselScreen(),
    );
  }
}
