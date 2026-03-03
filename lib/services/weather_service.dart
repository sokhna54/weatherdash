import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/weather_model.dart';

part 'weather_service.g.dart';


const String _apiKey = '8270bbb362ee5343ec473c2294538078';
const String _baseUrl = 'https://api.openweathermap.org/data/2.5/';

@RestApi(baseUrl: _baseUrl)
abstract class WeatherApi {
  factory WeatherApi(Dio dio, {String baseUrl}) = _WeatherApi;

  @GET('weather')
  Future<WeatherModel> getCityWeather(
    @Query('q') String city,
    @Query('appid') String apiKey,
    @Query('units') String units,
    @Query('lang') String lang,
  );
}

// ----- Repository -----
class WeatherService {
  late final WeatherApi _api;

  static const List<String> cities = [
    'Dakar',
    'Abidjan',
    'Casablanca',
    'Dubai',
    'Sydney',
  ];

  WeatherService() {
    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));
    _api = WeatherApi(dio);
  }

  Future<WeatherModel> fetchCity(String city) =>
      _api.getCityWeather(city, _apiKey, 'metric', 'fr');

  Future<List<WeatherModel>> fetchAll({
    required void Function(int index, String city) onProgress,
  }) async {
    final List<WeatherModel> results = [];
    for (int i = 0; i < cities.length; i++) {
      onProgress(i, cities[i]);
      await Future.delayed(const Duration(milliseconds: 600));
      final data = await fetchCity(cities[i]);
      results.add(data);
    }
    return results;
  }
}
