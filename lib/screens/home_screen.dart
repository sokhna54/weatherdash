import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../providers/weather_provider.dart';
import 'main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WeatherProvider>();
    final isDark = prov.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0A1628), const Color(0xFF1B2D4F), const Color(0xFF0D2137)]
                : [const Color(0xFF1565C0), const Color(0xFF42A5F5), const Color(0xFF80D8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -60, right: -60,
                child: Container(
                  width: 220, height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: 100, left: -80,
                child: Container(
                  width: 280, height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: prov.toggleTheme,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                                color: Colors.white, size: 22,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(flex: 1),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.5, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.elasticOut,
                          builder: (_, v, child) => Transform.scale(scale: v, child: child),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 180, height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(colors: [
                                    Colors.white.withOpacity(0.2),
                                    Colors.transparent,
                                  ]),
                                ),
                              ),
                              Container(
                                width: 120, height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: isDark
                                        ? [const Color(0xFFE0E0FF), const Color(0xFF9FA8DA)]
                                        : [const Color(0xFFFFE082), const Color(0xFFFFB300)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.2)
                                          : const Color(0xFFFFB300).withOpacity(0.5),
                                      blurRadius: 40, spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    isDark ? '🌙' : '☀️',
                                    style: const TextStyle(fontSize: 52),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'WeatherDash',
                          style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.w900,
                            color: Colors.white, letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedTextKit(
                          animatedTexts: [
                            FadeAnimatedText('Météo en temps réel',
                                textStyle: const TextStyle(fontSize: 16, color: Colors.white70)),
                            FadeAnimatedText('Pour 5 villes du monde',
                                textStyle: const TextStyle(fontSize: 16, color: Colors.white70)),
                            FadeAnimatedText('Powered by OpenWeatherMap',
                                textStyle: const TextStyle(fontSize: 16, color: Colors.white70)),
                          ],
                          repeatForever: true,
                        ),
                        const Spacer(flex: 2),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: ['🇸🇳 Dakar', '🇨🇮 Abidjan', '🇲🇦 Casablanca', '🇦🇪 Dubai', '🇦🇺 Sydney']
                              .map((c) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                                    ),
                                    child: Text(c,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 40),
                        _StartButton(onTap: () {
                          Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const MainScreen(),
                            transitionsBuilder: (_, anim, __, child) =>
                                FadeTransition(opacity: anim, child: child),
                            transitionDuration: const Duration(milliseconds: 500),
                          ));
                        }),
                        const SizedBox(height: 50),
                      ],
                    ),
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

class _StartButton extends StatefulWidget {
  final VoidCallback onTap;
  const _StartButton({required this.onTap});

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.04)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20, offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🌤️', style: TextStyle(fontSize: 22)),
              SizedBox(width: 10),
              Text("Voir la météo mondiale",
                  style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontSize: 17, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}
