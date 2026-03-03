// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'weather_service.dart';

class _WeatherApi implements WeatherApi {
  _WeatherApi(this._dio, {this.baseUrl}) {
    baseUrl ??= 'https://api.openweathermap.org/data/2.5/';
  }

  final Dio _dio;
  String? baseUrl;

  @override
  Future<WeatherModel> getCityWeather(
      String city,
      String apiKey,
      String units,
      String lang,
      ) async {
    final queryParameters = <String, dynamic>{
      'q': city,
      'appid': apiKey,
      'units': units,
      'lang': lang,
    };
    final result = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'GET').compose(
        _dio.options,
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: queryParameters,
      ),
    );
    return WeatherModel.fromJson(result.data!);
  }
}