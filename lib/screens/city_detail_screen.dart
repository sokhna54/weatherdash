import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';

class CityDetailScreen extends StatefulWidget {
  final WeatherModel weather;
  const CityDetailScreen({super.key, required this.weather});

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  GoogleMapController? _mapCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _mapCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WeatherProvider>();
    final isDark = prov.isDarkMode;
    final w = widget.weather;
    final mainDesc = w.weather.isNotEmpty ? w.weather.first.main : 'Clear';
    final emoji = prov.emojiFor(mainDesc);
    final accentColor = prov.colorFor(mainDesc);
    final cityLatLng = LatLng(w.coord.lat, w.coord.lon);

    return Scaffold(
      body: FadeTransition(
        opacity: _ctrl,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF0A1628), const Color(0xFF1B2D4F)]
                  : [const Color(0xFF1565C0), accentColor.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
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
                      const Spacer(),
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

                // Ville + temp principale
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 8),
                      Text(w.name,
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                      Text(w.weather.isNotEmpty ? w.weather.first.description : '',
                          style: const TextStyle(fontSize: 16, color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text('${w.main.temp.toStringAsFixed(0)}°C',
                          style: const TextStyle(
                              fontSize: 64, fontWeight: FontWeight.w900,
                              color: Colors.white, height: 1)),
                      Text('Ressenti ${w.main.feelsLike.toStringAsFixed(0)}°C',
                          style: const TextStyle(fontSize: 14, color: Colors.white60)),
                    ],
                  ),
                ),

                // Contenu scrollable
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0D1B2A) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          // Grille stats
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.7,
                            children: _buildStats(w).asMap().entries.map((e) {
                              final stat = e.value;
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: Duration(milliseconds: 250 + e.key * 70),
                                curve: Curves.easeOut,
                                builder: (_, v, child) => Opacity(opacity: v,
                                    child: Transform.translate(
                                        offset: Offset(0, 16 * (1 - v)), child: child)),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1B2D4F) : const Color(0xFFF0F7FF),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (stat['color'] as Color).withOpacity(0.1),
                                        blurRadius: 8, offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: (stat['color'] as Color).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(stat['icon'] as IconData,
                                            color: stat['color'] as Color, size: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(stat['label'] as String,
                                                style: TextStyle(fontSize: 11,
                                                    color: isDark ? Colors.white38 : Colors.grey)),
                                            Text(stat['value'] as String,
                                                style: TextStyle(fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // Google Maps
                          Row(children: [
                            const Icon(Icons.location_on_rounded, color: Color(0xFF1565C0), size: 20),
                            const SizedBox(width: 6),
                            Text('Localisation exacte',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                          ]),
                          const SizedBox(height: 4),
                          Text('Lat ${w.coord.lat.toStringAsFixed(4)}, Lon ${w.coord.lon.toStringAsFixed(4)}',
                              style: TextStyle(fontSize: 12,
                                  color: isDark ? Colors.white38 : Colors.grey)),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: SizedBox(
                              height: 240,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(target: cityLatLng, zoom: 10),
                                markers: {
                                  Marker(
                                    markerId: MarkerId(w.name),
                                    position: cityLatLng,
                                    infoWindow: InfoWindow(
                                      title: w.name,
                                      snippet: '${w.main.temp.toStringAsFixed(0)}°C — ${w.weather.isNotEmpty ? w.weather.first.description : ""}',
                                    ),
                                  ),
                                },
                                onMapCreated: (c) {
                                  _mapCtrl = c;
                                  if (isDark) c.setMapStyle(_darkStyle);
                                },
                                zoomControlsEnabled: false,
                                mapToolbarEnabled: false,
                                myLocationButtonEnabled: false,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildStats(WeatherModel w) => [
    {'icon': Icons.thermostat_rounded, 'label': 'Température', 'value': '${w.main.temp.toStringAsFixed(1)}°C', 'color': Colors.orange},
    {'icon': Icons.thermostat_auto_rounded, 'label': 'Ressenti', 'value': '${w.main.feelsLike.toStringAsFixed(1)}°C', 'color': Colors.deepOrange},
    {'icon': Icons.water_drop_rounded, 'label': 'Humidité', 'value': '${w.main.humidity}%', 'color': const Color(0xFF42A5F5)},
    {'icon': Icons.air_rounded, 'label': 'Vent', 'value': '${w.wind.speed.toStringAsFixed(1)} m/s', 'color': Colors.teal},
    {'icon': Icons.compress_rounded, 'label': 'Pression', 'value': '${w.main.pressure} hPa', 'color': Colors.purple},
    {'icon': Icons.visibility_rounded, 'label': 'Visibilité', 'value': '${(w.visibility / 1000).toStringAsFixed(1)} km', 'color': Colors.indigo},
    {'icon': Icons.arrow_upward_rounded, 'label': 'Max', 'value': '${w.main.tempMax.toStringAsFixed(0)}°C', 'color': Colors.red},
    {'icon': Icons.arrow_downward_rounded, 'label': 'Min', 'value': '${w.main.tempMin.toStringAsFixed(0)}°C', 'color': const Color(0xFF42A5F5)},
  ];
}

const _darkStyle = '''
[{"elementType":"geometry","stylers":[{"color":"#212121"}]},
 {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
 {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
 {"featureType":"road","elementType":"geometry","stylers":[{"color":"#383838"}]},
 {"featureType":"water","elementType":"geometry","stylers":[{"color":"#1a237e"}]}]
''';
