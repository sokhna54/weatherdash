import 'package:json_annotation/json_annotation.dart';

part 'weather_model.g.dart';

@JsonSerializable()
class WeatherModel {
  final String name;
  final MainWeather main;
  final List<WeatherDesc> weather;
  final Wind wind;
  final Coord coord;
  final int visibility;

  WeatherModel({
    required this.name,
    required this.main,
    required this.weather,
    required this.wind,
    required this.coord,
    required this.visibility,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherModelFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherModelToJson(this);
}

@JsonSerializable()
class MainWeather {
  final double temp;
  @JsonKey(name: 'feels_like')
  final double feelsLike;
  final int humidity;
  @JsonKey(name: 'temp_min')
  final double tempMin;
  @JsonKey(name: 'temp_max')
  final double tempMax;
  final int pressure;

  MainWeather({
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
  });

  factory MainWeather.fromJson(Map<String, dynamic> json) =>
      _$MainWeatherFromJson(json);
  Map<String, dynamic> toJson() => _$MainWeatherToJson(this);
}

@JsonSerializable()
class WeatherDesc {
  final String main;
  final String description;
  final String icon;

  WeatherDesc({
    required this.main,
    required this.description,
    required this.icon,
  });

  factory WeatherDesc.fromJson(Map<String, dynamic> json) =>
      _$WeatherDescFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherDescToJson(this);
}

@JsonSerializable()
class Wind {
  final double speed;
  Wind({required this.speed});
  factory Wind.fromJson(Map<String, dynamic> json) => _$WindFromJson(json);
  Map<String, dynamic> toJson() => _$WindToJson(this);
}

@JsonSerializable()
class Coord {
  final double lon;
  final double lat;
  Coord({required this.lon, required this.lat});
  factory Coord.fromJson(Map<String, dynamic> json) => _$CoordFromJson(json);
  Map<String, dynamic> toJson() => _$CoordToJson(this);
}
