import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_theme.dart';
import '../../models/esna_place.dart';
import '../../models/ride_order.dart';
import '../../providers/driver_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/role_drawer.dart';
import '../../widgets/weather_banner.dart';
import 'driver_active_trip_screen.dart';
import 'driver_wallet_screen.dart';
import 'driver_registration_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Realistic sample feed in Esna (Zero Penalty Feed)
  final List<RideOrder> _availableRequests = [
    RideOrder(
      id: 'req_esna_1',
      passengerId: 'p_101',
      passengerName: 'عبد الله قناوي',
      passengerPhone: '01055443322',
      pickupPlace: const EsnaPlace(
        id: 'p1',
        name: 'معبد إسنا (وسط البلد)',
        category: 'معالم إسنا',
        location: LatLng(25.2934, 32.5562),
        address: 'أمام مدخل المعبد الأثري',
      ),
      destinationPlace: const EsnaPlace(
        id: 'd1',
        name: 'مستشفى طيبة التخصصي',
        category: 'مستشفيات',
        location: LatLng(25.2845, 32.5480),
        address: 'طريق طيبة الزراعي',
      ),
      categoryId: 'toktok',
      initialSuggestedPrice: 20.0,
      passengerOfferedPrice: 20.0,
      agreedPrice: 20.0,
      polylinePoints: const [],
      distanceKm: 1.8,
      durationMinutes: 5.0,
      createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    RideOrder(
      id: 'req_esna_2',
      passengerId: 'p_102',
      passengerName: 'أبو الحسن محمد',
      passengerPhone: '01199887766',
      pickupPlace: const EsnaPlace(
        id: 'p2',
        name: 'كورنيش النيل (شارع البحر)',
        category: 'معالم إسنا',
        location: LatLng(25.2950, 32.5575),
        address: 'بجوار قناطر إسنا القديمة',
      ),
      destinationPlace: const EsnaPlace(
        id: 'd2',
        name: 'محطة قطار وموقف إسنا',
        category: 'مواقف',
        location: LatLng(25.2910, 32.5450),
        address: 'شارع المحطة',
      ),
      categoryId: 'motorcycle',
      initialSuggestedPrice: 15.0,
      passengerOfferedPrice: 15.0,
      agreedPrice: 15.0,
      polylinePoints: const [],
      distanceKm: 2.1,
      durationMinutes: 6.0,
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    RideOrder(
      id: 'req_esna_3',
      passengerId: 'p_103',
      passengerName: 'صيدلية السلام (مرسول طرد)',
      passengerPhone: '01211223344',
      pickupPlace: const EsnaPlace(
        id: 'p3',
        name: 'صيدلية السلام - شارع عرابي',
        category: 'صيدليات',
        location: LatLng(25.2905, 32.5535),
        address: 'السوق التجاري',
      ),
      destinationPlace: const EsnaPlace(
        id: 'd3',
        name: 'قرية الدير (شرق إسنا)',
        category: 'قرى',
        location: LatLng(25.3250, 32.5780),
        address: 'شارع المدرسة الإعدادية',
      ),
      categoryId: 'marsoul',
      initialSuggestedPrice: 40.0,
      passengerOfferedPrice: 35.0,
      agreedPrice: 35.0,
      polylinePoints: const [],
      distanceKm: 4.8,
      durationMinutes: 12.0,
      courierDetails: const CourierDetails(
        recipientPhone: '01011224455',
        itemName: 'روشتة علاج عاجلة',
        payer: 'المستلم',
        doorToDoor: true,
        qrDeliveryCode: 'ESNA-PARCEL-991',
      ),
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<DriverProvider, WalletProvider>(
      builder: (context, driverProv, walletProv, child) {
        if (driverProv.activeDriverTrip != null) {
          return const DriverActiveTripScreen();
        }

        return Scaffold(
          key: _scaffoldKey,
          drawer: const RoleDrawer(),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu, color: AppTheme.primaryLime),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driverProv.profile.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(
                  '${driverProv.profile.vehicleType} • ${driverProv.profile.vehicleNumber}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
            actions: [
              // Online Toggle
              Row(
                children: [
                  Text(
                    driverProv.isOnline ? 'متاح' : 'غير متصل',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: driverProv.isOnline ? AppTheme.primaryLime : AppTheme.textMuted,
                    ),
                  ),
                  Switch(
                    value: driverProv.isOnline,
                    onChanged: (_) => driverProv.toggleOnlineStatus(),
                    activeColor: AppTheme.primaryLime,
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Top Bar & Wallet Quick Peek
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('رصيد محفظة الكابتن:', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                        Text(
                          '${walletProv.balance.toStringAsFixed(1)} ج.م',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryLime),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DriverWalletScreen()),
                            );
                          },
                          icon: const Icon(Icons.add_card, size: 16),
                          label: const Text('شحن فوري'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            _showDriverQrCode(context, driverProv);
                          },
                          icon: const Icon(Icons.qr_code_2, color: AppTheme.primaryLime, size: 28),
                          tooltip: 'بطاقتي الرقمية',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Weather alert
              const WeatherBanner(),

              // Radar Header (Zero Penalty Feed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.radar, color: AppTheme.primaryLime, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'رادار الطلبات الحية في إسنا (Zero Penalty)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    Text(
                      '${_availableRequests.length} طلبات',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Feed List
              Expanded(
                child: !driverProv.isOnline
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.power_settings_new, size: 64, color: AppTheme.textMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'أنت غير متصل الآن',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'فعّل زر الاتصال بالأعلى لبدء تلقي طلبات الركاب والطرود بإسنا',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => driverProv.toggleOnlineStatus(),
                              child: const Text('الاتصال بالرادار الآن'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _availableRequests.length,
                        itemBuilder: (context, index) {
                          final request = _availableRequests[index];
                          return _buildOrderCard(context, request, driverProv, walletProv);
                        },
                      ),
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            color: AppTheme.darkSurface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DriverRegistrationScreen()),
                    );
                  },
                  icon: const Icon(Icons.badge_outlined, color: AppTheme.primaryLime),
                  label: const Text('المستندات والتوثيق', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DriverWalletScreen()),
                    );
                  },
                  icon: const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.primaryLime),
                  label: const Text('المحفظة والعمولة', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, RideOrder req, DriverProvider driverProv, WalletProvider walletProv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category & Distance tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLime.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  req.categoryId == 'toktok'
                      ? 'توك توك'
                      : (req.categoryId == 'motorcycle' ? 'موتوسيكل' : 'مرسول طرد'),
                  style: const TextStyle(
                    color: AppTheme.primaryLime,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.navigation_outlined, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${req.distanceKm} كم • ${req.durationMinutes} دقيقة',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Route Details
          Row(
            children: [
              const Icon(Icons.circle, color: AppTheme.primaryLime, size: 10),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  req.pickupPlace.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.more_vert, size: 14, color: AppTheme.textMuted),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.alertRed, size: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  req.destinationPlace.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Passenger offered price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('أجرة الراكب المعروضة:', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  Text(
                    '${req.passengerOfferedPrice.toInt()} ج.م',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryLime,
                    ),
                  ),
                ],
              ),
              // inDrive Negotiation options
              Row(
                children: [
                  // Counter offers buttons
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                    onPressed: () {
                      _acceptOrCounter(req, req.passengerOfferedPrice + 5, driverProv, walletProv);
                    },
                    child: const Text('+5 ج.م', style: TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                    onPressed: () {
                      _acceptOrCounter(req, req.passengerOfferedPrice + 10, driverProv, walletProv);
                    },
                    child: const Text('+10 ج.م', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Accept at passenger price or skip (Zero penalty)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    _acceptOrCounter(req, req.passengerOfferedPrice, driverProv, walletProv);
                  },
                  child: Text('قبول بسعر الراكب (${req.passengerOfferedPrice.toInt()} ج.م)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textMuted,
                    side: const BorderSide(color: AppTheme.darkBorder),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {
                    setState(() {
                      _availableRequests.removeWhere((r) => r.id == req.id);
                    });
                  },
                  child: const Text('تخطي'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _acceptOrCounter(RideOrder req, double price, DriverProvider driverProv, WalletProvider walletProv) {
    driverProv.acceptRide(req, price);
  }

  void _showDriverQrCode(BuildContext context, DriverProvider driverProv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 44, height: 5, decoration: BoxDecoration(color: AppTheme.darkBorder, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(
              'بطاقة هوية الكابتن (EsnaDrive ID)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${driverProv.profile.name} • ${driverProv.profile.vehicleType} (${driverProv.profile.vehicleNumber})',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Image.network(
                driverProv.driverQrUrl,
                width: 180,
                height: 180,
                errorBuilder: (_, __, ___) => const Icon(Icons.qr_code, size: 80, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
