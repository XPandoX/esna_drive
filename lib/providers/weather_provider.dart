import 'package:flutter/foundation.dart';
import '../core/services/public_apis_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherResult? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherResult? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  WeatherProvider() {
    fetchEsnaWeather();
  }

  Future<void> fetchEsnaWeather() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await PublicApisService.getEsnaWeather();
    } catch (e) {
      _errorMessage = 'تعذر جلب الطقس الحي: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
