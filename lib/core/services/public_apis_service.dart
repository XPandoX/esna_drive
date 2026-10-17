import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../constants/app_constants.dart';
import '../../models/esna_place.dart';

class RouteResult {
  final List<LatLng> polylinePoints;
  final double distanceKm;
  final double durationMinutes;
  final bool isLive;

  const RouteResult({
    required this.polylinePoints,
    required this.distanceKm,
    required this.durationMinutes,
    this.isLive = true,
  });
}

class WeatherResult {
  final double temperature;
  final int weatherCode;
  final double windSpeed;
  final bool isDay;
  final bool isExtremeHeat;
  final double heatBonus;

  const WeatherResult({
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.isDay,
    required this.isExtremeHeat,
    required this.heatBonus,
  });

  String get weatherDescription {
    if (temperature >= 38) return 'حر شديد (طقس صيف الصعيد)';
    if (weatherCode == 0) return 'طقس صافٍ ومثالي';
    if (weatherCode >= 1 && weatherCode <= 3) return 'غائم جزئياً';
    if (weatherCode >= 45 && weatherCode <= 48) return 'ضباب خفيف';
    if (weatherCode >= 51 && weatherCode <= 67) return 'أمطار خفيفة';
    return 'معتدل';
  }
}

class PublicApisService {
  static const Map<String, String> defaultHeaders = {
    'User-Agent': 'EsnaDriveApp/1.0 (esna.luxor.transport; contact: support@esnadrive.local)',
    'Accept': 'application/json',
  };

  /// 1. OSRM Route API
  static Future<RouteResult> getDrivingRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url, headers: defaultHeaders).timeout(
        const Duration(seconds: 6),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['code'] == 'Ok' && data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final double distanceMeters = (route['distance'] as num).toDouble();
          final double durationSeconds = (route['duration'] as num).toDouble();
          final List coordinates = route['geometry']['coordinates'] as List;

          final points = coordinates.map<LatLng>((coord) {
            return LatLng(
              (coord[1] as num).toDouble(),
              (coord[0] as num).toDouble(),
            );
          }).toList();

          return RouteResult(
            polylinePoints: points,
            distanceKm: double.parse((distanceMeters / 1000.0).toStringAsFixed(2)),
            durationMinutes: double.parse((durationSeconds / 60.0).toStringAsFixed(1)),
            isLive: true,
          );
        }
      }
    } catch (_) {
      // Fallback below
    }

    // Defensive Fallback: Realistic synthesized route with Haversine distance
    return _generateFallbackRoute(start, end);
  }

  /// 2. Nominatim OpenStreetMap Search
  static Future<List<EsnaPlace>> searchPlaces(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final encoded = Uri.encodeComponent('$cleanQuery إسنا الأقصر');
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$encoded&format=json&accept-language=ar&limit=8',
    );

    try {
      final response = await http.get(url, headers: defaultHeaders).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final List list = json.decode(utf8.decode(response.bodyBytes));
        if (list.isNotEmpty) {
          return list.map((item) {
            return EsnaPlace(
              id: item['place_id']?.toString() ?? 'place_${DateTime.now().microsecondsSinceEpoch}',
              name: _cleanDisplayName(item['display_name'] ?? cleanQuery),
              category: 'بحث الخريطة',
              location: LatLng(
                double.parse(item['lat']),
                double.parse(item['lon']),
              ),
              address: item['display_name'] ?? '',
            );
          }).toList();
        }
      }
    } catch (_) {}

    // Fallback: search in local landmarks
    return _searchLocalLandmarks(cleanQuery);
  }

  /// 2b. Nominatim Reverse Geocoding
  static Future<String> reverseGeocode(LatLng point) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json&accept-language=ar',
    );

    try {
      final response = await http.get(url, headers: defaultHeaders).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final displayName = data['display_name'];
        if (displayName != null && displayName.toString().isNotEmpty) {
          return _cleanDisplayName(displayName.toString());
        }
      }
    } catch (_) {}

    // Fallback nearest landmark name
    return _findNearestLandmarkName(point);
  }

  /// 3. Overpass API for Live Pharmacies, Restaurants & Services in Esna
  static Future<List<EsnaPlace>> getEsnaServices({String categoryFilter = 'all'}) async {
    const String query =
        '[out:json][timeout:10];'
        '('
        'node["amenity"~"pharmacy|restaurant|hospital|cafe"](around:5000, 25.2899, 32.5522);'
        'node["shop"~"bakery|supermarket"](around:5000, 25.2899, 32.5522);'
        ');'
        'out 25;';

    final url = Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}');

    try {
      final response = await http.get(url, headers: defaultHeaders).timeout(
        const Duration(seconds: 6),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final elements = data['elements'] as List?;
        if (elements != null && elements.isNotEmpty) {
          final places = <EsnaPlace>[];
          for (final el in elements) {
            final tags = el['tags'] as Map<String, dynamic>? ?? {};
            final name = tags['name:ar'] ?? tags['name'] ?? _resolveAmenityName(tags);
            final amenity = tags['amenity'] ?? tags['shop'] ?? 'service';
            final lat = (el['lat'] as num).toDouble();
            final lon = (el['lon'] as num).toDouble();

            places.add(
              EsnaPlace(
                id: el['id'].toString(),
                name: name,
                category: _mapAmenityToCategory(amenity),
                location: LatLng(lat, lon),
                address: tags['addr:street'] ?? 'إسنا - الأقصر',
                phone: tags['phone'] ?? tags['contact:phone'],
              ),
            );
          }
          if (places.isNotEmpty) return places;
        }
      }
    } catch (_) {}

    // Immediate Local Fallback
    return _getLocalEsnaServices();
  }

  /// 4. Open-Meteo Weather API
  static Future<WeatherResult> getEsnaWeather() async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=25.2899&longitude=32.5522&current_weather=true',
    );

    try {
      final response = await http.get(url, headers: defaultHeaders).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final cw = data['current_weather'];
        final double temp = (cw['temperature'] as num).toDouble();
        final int code = (cw['weathercode'] as num).toInt();
        final double wind = (cw['windspeed'] as num).toDouble();
        final bool isDay = (cw['is_day'] as num) == 1;

        final isExtremeHeat = temp >= AppConstants.extremeHeatThreshold;
        final heatBonus = isExtremeHeat ? AppConstants.heatBonusEgp : 0.0;

        return WeatherResult(
          temperature: temp,
          weatherCode: code,
          windSpeed: wind,
          isDay: isDay,
          isExtremeHeat: isExtremeHeat,
          heatBonus: heatBonus,
        );
      }
    } catch (_) {}

    // Fallback
    return const WeatherResult(
      temperature: 28.5,
      weatherCode: 0,
      windSpeed: 8.5,
      isDay: true,
      isExtremeHeat: false,
      heatBonus: 0.0,
    );
  }

  /// 5. QRServer API URL Generator
  static String getQrCodeUrl(String data, {int size = 250}) {
    final encoded = Uri.encodeComponent(data);
    return 'https://api.qrserver.com/v1/create-qr-code/?size=${size}x$size&data=$encoded';
  }

  /// 6. DiceBear Avatar API URL Generator
  static String getAvatarUrl(String seed) {
    final cleanSeed = Uri.encodeComponent(seed);
    return 'https://api.dicebear.com/7.x/avataaars/png?seed=$cleanSeed';
  }

  // --- Helpers & Fallbacks ---

  static String _cleanDisplayName(String raw) {
    final parts = raw.split(',');
    if (parts.length > 2) {
      return '${parts[0].trim()} - ${parts[1].trim()}';
    }
    return raw.trim();
  }

  static RouteResult _generateFallbackRoute(LatLng start, LatLng end) {
    final distanceMeters = _calculateHaversineDistance(start, end);
    final distanceKm = double.parse((distanceMeters / 1000.0).toStringAsFixed(2));
    // Estimate 25 km/h for TokTok/Motorcycle in Esna streets
    final durationMinutes = double.parse(((distanceKm / 25.0) * 60.0 + 2.0).toStringAsFixed(1));

    // Synthesize intermediate road points along path
    final points = <LatLng>[start];
    const steps = 6;
    for (int i = 1; i < steps; i++) {
      final fraction = i / steps;
      final lat = start.latitude + (end.latitude - start.latitude) * fraction;
      final lon = start.longitude + (end.longitude - start.longitude) * fraction;
      // Add slight road curvature
      final offset = sin(fraction * pi) * 0.0008;
      points.add(LatLng(lat + offset, lon - offset));
    }
    points.add(end);

    return RouteResult(
      polylinePoints: points,
      distanceKm: distanceKm < 0.3 ? 0.5 : distanceKm,
      durationMinutes: durationMinutes < 2 ? 3 : durationMinutes,
      isLive: false,
    );
  }

  static double _calculateHaversineDistance(LatLng p1, LatLng p2) {
    const double r = 6371000; // meters
    final dLat = (p2.latitude - p1.latitude) * pi / 180.0;
    final dLon = (p2.longitude - p1.longitude) * pi / 180.0;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(p1.latitude * pi / 180.0) *
            cos(p2.latitude * pi / 180.0) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static List<EsnaPlace> _searchLocalLandmarks(String q) {
    final results = <EsnaPlace>[];
    for (final l in AppConstants.esnaLandmarks) {
      if (l.name.contains(q) || l.description.contains(q)) {
        results.add(
          EsnaPlace(
            id: l.id,
            name: l.name,
            category: 'معالم إسنا',
            location: l.location,
            address: l.description,
          ),
        );
      }
    }
    if (results.isEmpty) {
      // Default to center
      results.add(
        EsnaPlace(
          id: 'custom_query',
          name: '$q (إسنا)',
          category: 'موقع مخصص',
          location: AppConstants.esnaCenter,
          address: 'مدينة إسنا - محافظة الأقصر',
        ),
      );
    }
    return results;
  }

  static String _findNearestLandmarkName(LatLng point) {
    double minDistance = double.infinity;
    String closestName = 'شارع عام بإسنا';

    for (final l in AppConstants.esnaLandmarks) {
      final d = _calculateHaversineDistance(point, l.location);
      if (d < minDistance) {
        minDistance = d;
        closestName = l.name;
      }
    }
    return minDistance < 400 ? closestName : 'بالقرب من $closestName';
  }

  static String _resolveAmenityName(Map<String, dynamic> tags) {
    final amenity = tags['amenity'] ?? tags['shop'] ?? '';
    switch (amenity) {
      case 'pharmacy':
        return 'صيدلية بإسنا';
      case 'restaurant':
        return 'مطعم ومأكولات بإسنا';
      case 'hospital':
        return 'مركز طبي بإسنا';
      case 'bakery':
        return 'مخبز بلدي بإسنا';
      default:
        return 'محل تجاري بإسنا';
    }
  }

  static String _mapAmenityToCategory(String amenity) {
    switch (amenity) {
      case 'pharmacy':
        return 'صيدليات';
      case 'restaurant':
      case 'cafe':
        return 'مطاعم وكافيهات';
      case 'hospital':
        return 'مستشفيات ومراكز طبية';
      case 'bakery':
      case 'supermarket':
        return 'سوبرماركت ومخابز';
      default:
        return 'خدمات ومحلات';
    }
  }

  static List<EsnaPlace> _getLocalEsnaServices() {
    return const [
      EsnaPlace(
        id: 'pharmacy_1',
        name: 'صيدلية السلام الكبرى',
        category: 'صيدليات',
        location: LatLng(25.2925, 32.5545),
        address: 'شارع أحمد عرابي - وسط إسنا',
        phone: '01012345671',
      ),
      EsnaPlace(
        id: 'pharmacy_2',
        name: 'صيدلية د. فلان التخصصية',
        category: 'صيدليات',
        location: LatLng(25.2850, 32.5485),
        address: 'أمام مستشفى طيبة التخصصي',
        phone: '01123456782',
      ),
      EsnaPlace(
        id: 'pharmacy_3',
        name: 'صيدلية النيل الحديثة',
        category: 'صيدليات',
        location: LatLng(25.2940, 32.5570),
        address: 'شارع البحر كورنيش النيل',
        phone: '01234567893',
      ),
      EsnaPlace(
        id: 'restaurant_1',
        name: 'مطعم البرنس للمأكولات الشرقية',
        category: 'مطاعم وكافيهات',
        location: LatLng(25.2915, 32.5530),
        address: 'ميدان الرجعية - السوق التجاري',
        phone: '01099887766',
      ),
      EsnaPlace(
        id: 'restaurant_2',
        name: 'كشري الزعيم إسنا',
        category: 'مطاعم وكافيهات',
        location: LatLng(25.2900, 32.5510),
        address: 'بجوار محطة قطار إسنا',
        phone: '01155443322',
      ),
      EsnaPlace(
        id: 'restaurant_3',
        name: 'أسماك النيل الطازجة',
        category: 'مطاعم وكافيهات',
        location: LatLng(25.2960, 32.5580),
        address: 'كورنيش النيل بجوار القناطر',
        phone: '01211223344',
      ),
      EsnaPlace(
        id: 'hospital_1',
        name: 'مستشفى طيبة التخصصي بإسنا',
        category: 'مستشفيات ومراكز طبية',
        location: LatLng(25.2845, 32.5480),
        address: 'طريق مصر أسوان الزراعي - إسنا',
        phone: '0952510100',
      ),
      EsnaPlace(
        id: 'hospital_2',
        name: 'المركز الطبي الحضري',
        category: 'مستشفيات ومراكز طبية',
        location: LatLng(25.2930, 32.5520),
        address: 'شارع البحرية القديم',
        phone: '0952510200',
      ),
      EsnaPlace(
        id: 'bakery_1',
        name: 'مخبز وفطاطري البركة',
        category: 'سوبرماركت ومخابز',
        location: LatLng(25.2908, 32.5538),
        address: 'شارع أحمد عرابي',
        phone: '01033445566',
      ),
      EsnaPlace(
        id: 'market_1',
        name: 'سوبرماركت أولاد رجب إسنا',
        category: 'سوبرماركت ومخابز',
        location: LatLng(25.2920, 32.5550),
        address: 'طريق معبد إسنا الرئيسي',
        phone: '01177889900',
      ),
    ];
  }
}
