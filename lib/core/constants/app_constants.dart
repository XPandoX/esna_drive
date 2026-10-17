import 'package:latlong2/latlong.dart';

class EsnaLandmark {
  final String id;
  final String name;
  final String description;
  final LatLng location;
  final String icon;

  const EsnaLandmark({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.icon,
  });
}

class ServiceCategory {
  final String id;
  final String name;
  final String subtitle;
  final double basePrice;
  final double perKmPrice;
  final String capacity;
  final String iconName;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.basePrice,
    required this.perKmPrice,
    required this.capacity,
    required this.iconName,
  });
}

class AppConstants {
  static const String appName = 'إسنا درايف';
  static const String appTagline = 'مشوارك بسعرك - توك توك وموتوسيكل ومرسول في إسنا';
  
  // Center of Esna city
  static const LatLng esnaCenter = LatLng(25.2899, 32.5522);
  static const double defaultZoom = 14.5;

  // Demo OTP Code
  static const String demoOtp = '1234';

  // Default Platform Commission
  static const double defaultCommissionRate = 0.07; // 7%

  // High Heat Threshold in Upper Egypt
  static const double extremeHeatThreshold = 38.0;
  static const double heatBonusEgp = 5.0;

  // 10 Key Landmarks in Esna
  static const List<EsnaLandmark> esnaLandmarks = [
    EsnaLandmark(
      id: 'khnum_temple',
      name: 'معبد إسنا (معبد خنوم)',
      description: 'وسط البلد - شارع المعبد القديم',
      location: LatLng(25.2934, 32.5562),
      icon: 'temple',
    ),
    EsnaLandmark(
      id: 'corniche',
      name: 'كورنيش النيل بإسنا',
      description: 'شارع البحر - إطلالة النيل الساحرة',
      location: LatLng(25.2950, 32.5575),
      icon: 'water',
    ),
    EsnaLandmark(
      id: 'tiba_hospital',
      name: 'مستشفى طيبة التخصصي',
      description: 'طريق طيبة - المركز الطبي الرئيسي',
      location: LatLng(25.2845, 32.5480),
      icon: 'hospital',
    ),
    EsnaLandmark(
      id: 'barrage',
      name: 'قناطر إسنا الجديدة',
      description: 'كوبري قناطر إسنا والممشى السياحي',
      location: LatLng(25.3160, 32.5540),
      icon: 'bridge',
    ),
    EsnaLandmark(
      id: 'station',
      name: 'محطة قطار وموقف الأقاليم',
      description: 'موقف السفر ومحطة السكة الحديد',
      location: LatLng(25.2910, 32.5450),
      icon: 'train',
    ),
    EsnaLandmark(
      id: 'orabi_street',
      name: 'شارع أحمد عرابي والسوق',
      description: 'المنطقة التجارية والأسواق الشعبية',
      location: LatLng(25.2905, 32.5535),
      icon: 'store',
    ),
    EsnaLandmark(
      id: 'village_deir',
      name: 'قرية الدير (شرق إسنا)',
      description: 'الجهة الشرقية عبر النيل والكوبري',
      location: LatLng(25.3250, 32.5780),
      icon: 'village',
    ),
    EsnaLandmark(
      id: 'village_hella',
      name: 'قرية الحلة',
      description: 'جنوب شرق إسنا - المحور الزراعي',
      location: LatLng(25.2450, 32.5650),
      icon: 'village',
    ),
    EsnaLandmark(
      id: 'village_nemsa',
      name: 'قرية النمسا',
      description: 'جنوب إسنا - خط المراكز',
      location: LatLng(25.2150, 32.5420),
      icon: 'village',
    ),
    EsnaLandmark(
      id: 'village_keman',
      name: 'قرية كيمان المطاعنة',
      description: 'شمال غرب إسنا - منطقة المطاعنة',
      location: LatLng(25.3850, 32.5120),
      icon: 'village',
    ),
  ];

  // 4 Service Categories tailored for Esna
  static const List<ServiceCategory> categories = [
    ServiceCategory(
      id: 'toktok',
      name: 'توك توك',
      subtitle: 'مشوار مريح داخل شوارع إسنا',
      basePrice: 15.0,
      perKmPrice: 5.0,
      capacity: '1 - 3 ركاب',
      iconName: 'electric_rickshaw',
    ),
    ServiceCategory(
      id: 'motorcycle',
      name: 'موتوسيكل',
      subtitle: 'أسرع مشوار لتخطي الزحام',
      basePrice: 10.0,
      perKmPrice: 3.5,
      capacity: 'فرد واحد',
      iconName: 'two_wheeler',
    ),
    ServiceCategory(
      id: 'marsoul',
      name: 'مرسول إسنا',
      subtitle: 'توصيل طلبات وأدوية وطرود',
      basePrice: 20.0,
      perKmPrice: 4.0,
      capacity: 'طرود حتى 20 كجم',
      iconName: 'local_shipping',
    ),
    ServiceCategory(
      id: 'villages',
      name: 'مشاوير القرى',
      subtitle: 'الدير، الحلة، النمسا، الكيمان',
      basePrice: 25.0,
      perKmPrice: 4.5,
      capacity: 'عائلات ومجموعات',
      iconName: 'commute',
    ),
  ];

  // Emergency SOS Numbers in Egypt
  static const String policeEmergency = '122';
  static const String ambulanceEmergency = '123';
  static const String trafficPolice = '128';

  // Prohibited Items for Marsoul
  static const List<String> prohibitedItems = [
    'الأموال النقدية والذهب والمجوهرات الثمينة',
    'المواد القابلة للاشتعال أو المتفجرة',
    'أي مواد أو عقاقير محظورة قانونياً بدون روشتة',
    'الحيوانات الحية أو اللحوم غير المحفوظة',
    'الطرود الثقيلة التي تتعدى 20 كجم',
  ];

  // 4 Allowed Fare Increase Conditions (inDrive Pact)
  static const List<Map<String, String>> allowedFareIncreaseRules = [
    {
      'title': '1. تغيير المسار الفعلي',
      'desc': 'إذا طلب الراكب سلوك مسار أطول بمسافة ملحوظة عن المسار المتفق عليه.',
    },
    {
      'title': '2. تعديل أو إضافة وجهة جديدة',
      'desc': 'في حال طلب الراكب النزول في نقطة أخرى أو إضافة نقطة توقف إضافية.',
    },
    {
      'title': '3. وقت انتظار مجاني يتعدى 5 دقائق',
      'desc': 'يحق للكابتن حساب انتظار إضافي بعد استنفاد الدقائق الخمس المجانية الأولى.',
    },
    {
      'title': '4. التوقف والانتظار أثناء الرحلة',
      'desc': 'عند طلب الراكب التوقف أمام محل أو صيدلية وقضاء حاجة أثناء الرحلة.',
    },
  ];
}
