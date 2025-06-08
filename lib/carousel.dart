import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class OnboardingItem {
  final String image, title, description;
  const OnboardingItem({required this.image, required this.title, required this.description});
}

class CarouselScreen extends StatefulWidget {
  const CarouselScreen({super.key});

  @override
  State<CarouselScreen> createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> with TickerProviderStateMixin {
  final List<OnboardingItem> items = const [
    OnboardingItem(
      image: 'assets/images/C1.png',
      title: 'Organiza tus anestesias',
      description: 'Lleva el control de tus procedimientos de manera clara y eficiente.',
    ),
    OnboardingItem(
      image: 'assets/images/C2.png',
      title: 'Acceso rápido',
      description: 'Consulta rápidamente historiales y fichas clínicas.',
    ),
    OnboardingItem(
      image: 'assets/images/C3.png',
      title: 'Seguridad primero',
      description: 'Mantén tus datos protegidos con autenticación segura.',
    ),
  ];

  int currentIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  late final AnimationController _btnController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _btnController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, CarouselPageChangedReason reason) {
    setState(() {
      currentIndex = index;
    });

    if (index == items.length - 1) {
      _btnController.forward();
    } else {
      _btnController.reverse();
    }
  }

  Future<void> _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Widget _buildPage(OnboardingItem item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(item.image, height: 220),
        const SizedBox(height: 30),
        Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            item.description,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(items.length, (index) {
        final isActive = currentIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: CarouselSlider.builder(
                    carouselController: _carouselController,
                    itemCount: items.length,
                    itemBuilder: (_, index, __) => _buildPage(items[index]),
                    options: CarouselOptions(
                      height: double.infinity,
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                      onPageChanged: _onPageChanged,
                    ),
                  ),
                ),
                _buildIndicators(),
                const SizedBox(height: 30),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: ElevatedButton(
                        onPressed: _goToLogin,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Iniciar sesión'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
            Positioned(
              top: 16,
              right: 16,
              child: currentIndex < items.length - 1
                  ? TextButton(
                onPressed: _goToLogin,
                child: const Text(
                  'Saltar',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
