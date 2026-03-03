import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

enum AppStatus { idle, loading, success, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  // ---- État ----
  AppStatus status = AppStatus.idle;
  List<WeatherModel> cities = [];
  String errorMessage = '';
  double progress = 0.0;
  String currentCity = '';
  int currentIndex = 0;
  bool isDarkMode = false;

  // Messages d'attente tournant en boucle
  static const List<String> _waitMessages = [
    'Nous téléchargeons les données...',
    "C'est presque fini...",
    "Plus que quelques secondes avant d'avoir le résultat...",
    'Récupération des données météo...',
    'Connexion aux serveurs en cours...',
  ];

  String get waitMessage => _waitMessages[currentIndex % _waitMessages.length];

  // ---- Méthodes ----
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void reset() {
    status = AppStatus.idle;
    cities = [];
    errorMessage = '';
    progress = 0.0;
    currentCity = '';
    currentIndex = 0;
    notifyListeners();
  }

  Future<void> loadWeather() async {
    status = AppStatus.loading;
    cities = [];
    progress = 0.0;
    errorMessage = '';
    notifyListeners();

    try {
      final results = await _service.fetchAll(
        onProgress: (index, city) {
          currentIndex = index;
          currentCity = city;
          progress = index / WeatherService.cities.length;
          notifyListeners();
        },
      );
      cities = results;
      progress = 1.0;
      status = AppStatus.success;
    } catch (e) {
      errorMessage = e.toString().replaceAll('DioException', 'Erreur réseau');
      status = AppStatus.error;
    }

    notifyListeners();
  }

  // ---- Helpers UI ----
  String emojiFor(String main) {
    switch (main.toLowerCase()) {
      case 'clear':       return '☀️';
      case 'clouds':      return '☁️';
      case 'rain':        return '🌧️';
      case 'drizzle':     return '🌦️';
      case 'thunderstorm':return '⛈️';
      case 'snow':        return '❄️';
      case 'mist':
      case 'fog':
      case 'haze':        return '🌫️';
      default:            return '🌤️';
    }
  }

  Color colorFor(String main) {
    switch (main.toLowerCase()) {
      case 'clear':       return const Color(0xFFFFB703);
      case 'rain':
      case 'drizzle':     return const Color(0xFF4CC9F0);
      case 'thunderstorm':return const Color(0xFF7209B7);
      case 'snow':        return const Color(0xFFADE8F4);
      default:            return const Color(0xFF3B82F6);
    }
  }
}
