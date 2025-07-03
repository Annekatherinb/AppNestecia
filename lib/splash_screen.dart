import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'carousel.dart';

class SplashScreenApp extends StatefulWidget {
  final bool showOnboarding;
  const SplashScreenApp({super.key, required this.showOnboarding});

  @override
  State<SplashScreenApp> createState() => _SplashScreenAppState();
}

class _SplashScreenAppState extends State<SplashScreenApp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _animatedBackground() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 6),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [value * 0.3, 0.8],
              colors: [
                Color.lerp(const Color(0xFF003366), const Color(0xFF00B4D8), value)!,
                Color.lerp(const Color(0xFFCAF0F8), const Color(0xFF0077B6), 1 - value)!,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHologramLogo() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: -0.2, end: 0.2),
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      builder: (context, angle, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/principalLOG.png',
              height: 160,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _animatedBackground(),

        // Fondo oscuro transparente
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.1),
          ),
        ),

        AnimatedSplashScreen(
          backgroundColor: Colors.transparent,
          splashIconSize: 400,
          duration: 3500,
          splashTransition: SplashTransition.fadeTransition,
          pageTransitionType: PageTransitionType.fade,
          splash: FadeScaleTransition(
            animation: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHologramLogo(),
                  const SizedBox(height: 20),
                  DefaultTextStyle(
                    style: GoogleFonts.montserrat(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 18.0,
                          color: Colors.cyanAccent,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(
                          "AppNestesia",
                          speed: Duration(milliseconds: 100),
                        ),
                      ],
                      totalRepeatCount: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          nextScreen: const CarouselScreen(),
        ),
      ],
    );
  }
}
