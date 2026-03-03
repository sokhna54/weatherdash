import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: const WeatherWorldApp(),
    ),
  );
}

class WeatherWorldApp extends StatelessWidget {
  const WeatherWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<WeatherProvider>().isDarkMode;
    return MaterialApp(
      title: 'WeatherDash',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF1565C0),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF1565C0),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
