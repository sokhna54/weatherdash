# 🌍 WeatherWorld — Examen Développement Mobile L3GL ISI 2026

> Application Flutter — météo en temps réel pour 5 villes mondiales



## 👥 Membres du groupe

| Nom   | Prénom          |   
|-------|---------------- |
| DIENG |  seynabou Gueye |
|  SOW  |   AWA           |
|BARRY  | Sokhna          | 





## 🗂️ Structure du projet


lib/
├── main.dart                        # Entrée + thème
├── models/
│   ├── weather_model.dart           # Modèle données
│   └── weather_model.g.dart         # JSON généré
├── services/
│   ├── weather_service.dart         # API Retrofit
│   └── weather_service.g.dart       # Code généré
├── providers/
│   └── weather_provider.dart        # State management
└── screens/
    ├── home_screen.dart             # Écran 1 — Accueil
    ├── main_screen.dart             # Écran 2 — Jauge + liste
    └── city_detail_screen.dart      # Écran 3 — Détail + Maps
android/
└── app/src/main/AndroidManifest.xml # Clé Google Maps + permissions


