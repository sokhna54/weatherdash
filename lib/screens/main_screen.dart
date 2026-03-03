import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../providers/weather_provider.dart';
import '../services/weather_service.dart';
import 'city_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<WeatherProvider>();
      if (prov.status == AppStatus.idle || prov.status == AppStatus.error) {
        prov.loadWeather();
      }
    });
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
                ? [const Color(0xFF0A1628), const Color(0xFF1B2D4F)]
                : [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar custom
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('Météo Mondiale',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    GestureDetector(
                      onTap: prov.toggleTheme,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                          color: Colors.white, size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Jauge
              _GaugeCard(prov: prov, isDark: isDark),

              const SizedBox(height: 12),

              // Liste
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0D1B2A) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: _buildBody(prov, isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(WeatherProvider prov, bool isDark) {
    if (prov.status == AppStatus.loading && prov.cities.isEmpty) {
      return _LoadingList(prov: prov, isDark: isDark);
    }
    if (prov.status == AppStatus.error) {
      return _ErrorView(prov: prov, isDark: isDark);
    }
    return _CityList(prov: prov, isDark: isDark);
  }
}

class _GaugeCard extends StatelessWidget {
  final WeatherProvider prov;
  final bool isDark;
  const _GaugeCard({required this.prov, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isError = prov.status == AppStatus.error;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 50,
            lineWidth: 8,
            percent: prov.progress,
            animation: true,
            animateFromLastPercent: true,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${(prov.progress * 100).toInt()}%',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('${prov.cities.length}/5',
                    style: const TextStyle(fontSize: 10, color: Colors.white60)),
              ],
            ),
            progressColor: isError ? Colors.red : Colors.white,
            backgroundColor: Colors.white.withOpacity(0.2),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 16),
          Expanded(child: _StatusMessage(prov: prov)),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final WeatherProvider prov;
  const _StatusMessage({required this.prov});

  @override
  Widget build(BuildContext context) {
    if (prov.status == AppStatus.success) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💥 BOOM !', style: TextStyle(fontSize: 20, color: Colors.white)),
          SizedBox(height: 4),
          Text('Toutes les villes chargées !',
              style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
        ],
      );
    }
    if (prov.status == AppStatus.error) {
      return const Text('❌ Erreur\nVérifiez votre clé API',
          style: TextStyle(fontSize: 13, color: Colors.redAccent));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('📡 ${prov.currentCity}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        AnimatedTextKit(
          key: ValueKey(prov.currentIndex),
          animatedTexts: [
            FadeAnimatedText(prov.waitMessage,
                textStyle: const TextStyle(fontSize: 12, color: Colors.white60, fontStyle: FontStyle.italic),
                duration: const Duration(milliseconds: 2500)),
          ],
          totalRepeatCount: 1,
        ),
      ],
    );
  }
}

class _LoadingList extends StatelessWidget {
  final WeatherProvider prov;
  final bool isDark;
  const _LoadingList({required this.prov, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      children: WeatherService.cities.asMap().entries.map((e) {
        final i = e.key;
        final city = e.value;
        final done = i < prov.cities.length;
        final active = i == prov.currentIndex && !done;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B2D4F).withOpacity(0.6) : const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(14),
            border: active ? Border.all(color: const Color(0xFF42A5F5), width: 1.5) : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? const Color(0xFF42A5F5)
                      : active
                          ? const Color(0xFF1565C0)
                          : (isDark ? const Color(0xFF1B2D4F) : const Color(0xFFE3F2FD)),
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                      : active
                          ? const SizedBox(width: 15, height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('${i + 1}',
                              style: TextStyle(
                                  color: isDark ? Colors.white38 : Colors.grey,
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 14),
              Text(city,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: active || done ? FontWeight.w700 : FontWeight.w400,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final WeatherProvider prov;
  final bool isDark;
  const _ErrorView({required this.prov, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text('❌', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text("L'API météo a fait des siennes !",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            Text(prov.errorMessage, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 13)),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: prov.loadWeather,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityList extends StatelessWidget {
  final WeatherProvider prov;
  final bool isDark;
  const _CityList({required this.prov, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        ...prov.cities.asMap().entries.map((e) => _CityCard(
              weather: e.value, index: e.key, prov: prov, isDark: isDark)),
        const SizedBox(height: 12),
        if (prov.status == AppStatus.success)
          ElevatedButton.icon(
            onPressed: () { prov.reset(); Navigator.pop(context); },
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Recommencer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
      ],
    );
  }
}

class _CityCard extends StatefulWidget {
  final dynamic weather;
  final int index;
  final WeatherProvider prov;
  final bool isDark;

  const _CityCard({required this.weather, required this.index,
      required this.prov, required this.isDark});

  @override
  State<_CityCard> createState() => _CityCardState();
}

class _CityCardState extends State<_CityCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0.2, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 80),
        () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final w = widget.weather;
    final mainDesc = w.weather.isNotEmpty ? w.weather.first.main : 'Clear';
    final emoji = widget.prov.emojiFor(mainDesc);
    final accentColor = widget.prov.colorFor(mainDesc);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => CityDetailScreen(weather: w))),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDark
                    ? [const Color(0xFF1B2D4F), const Color(0xFF162236)]
                    : [Colors.white, const Color(0xFFF0F7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.15),
                  blurRadius: 12, offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w.name,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                              color: widget.isDark ? Colors.white : const Color(0xFF1A1A2E))),
                      const SizedBox(height: 3),
                      Text(w.weather.isNotEmpty ? w.weather.first.description : '',
                          style: TextStyle(fontSize: 13,
                              color: widget.isDark ? Colors.white54 : const Color(0xFF64748B))),
                      const SizedBox(height: 5),
                      Row(children: [
                        Icon(Icons.water_drop_outlined, size: 12, color: const Color(0xFF42A5F5)),
                        const SizedBox(width: 3),
                        Text('${w.main.humidity}%',
                            style: TextStyle(fontSize: 12,
                                color: widget.isDark ? Colors.white38 : Colors.grey)),
                        const SizedBox(width: 12),
                        Icon(Icons.air_rounded, size: 12, color: const Color(0xFF42A5F5)),
                        const SizedBox(width: 3),
                        Text('${w.wind.speed.toStringAsFixed(1)} m/s',
                            style: TextStyle(fontSize: 12,
                                color: widget.isDark ? Colors.white38 : Colors.grey)),
                      ]),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${w.main.temp.toStringAsFixed(0)}°',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: accentColor)),
                    Text('Ressenti ${w.main.feelsLike.toStringAsFixed(0)}°',
                        style: TextStyle(fontSize: 11,
                            color: widget.isDark ? Colors.white38 : Colors.grey)),
                    const SizedBox(height: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 13, color: accentColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
