import 'package:flutter/foundation.dart';
import '../models/driver_profile.dart';
import '../models/wallet_transaction.dart';

class AdminProvider extends ChangeNotifier {
  double _commissionRate = 0.07; // 7%
  double _toktokBasePrice = 15.0;
  double _toktokPerKm = 5.0;
  double _motoBasePrice = 10.0;
  double _motoPerKm = 3.5;
  double _marsoulBasePrice = 20.0;
  double _marsoulPerKm = 4.0;

  final List<DriverProfile> _drivers = [
    const DriverProfile(
      id: 'driver_01',
      name: 'محمود عبد الرازق (الأسطى حودة)',
      phone: '01098765432',
      vehicleType: 'توك توك',
      vehicleNumber: 'إسنا - 418',
      isVerified: true,
      walletBalance: 240.0,
      rating: 4.95,
      totalRides: 512,
      qrCodeData: 'ESNA-DRIVER-01-TOUTKOUK-418',
    ),
    const DriverProfile(
      id: 'driver_02',
      name: 'كابتن إبراهيم النمساوي',
      phone: '01123487654',
      vehicleType: 'موتوسيكل',
      vehicleNumber: 'أ ق ص 9231',
      isVerified: true,
      walletBalance: 110.0,
      rating: 4.88,
      totalRides: 284,
      qrCodeData: 'ESNA-DRIVER-02-MOTO-9231',
    ),
    const DriverProfile(
      id: 'driver_03',
      name: 'علي حسن العطواني',
      phone: '01287654321',
      vehicleType: 'توك توك',
      vehicleNumber: 'إسنا - 702',
      isVerified: false, // Pending verification
      walletBalance: 50.0,
      rating: 5.0,
      totalRides: 12,
      qrCodeData: 'ESNA-DRIVER-03-TOUTKOUK-702',
    ),
  ];

  final List<WalletTransaction> _pendingTopUps = [
    WalletTransaction(
      id: 'topup_fawry_9921',
      type: TransactionType.topUp,
      amount: 100.0,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      description: 'شحن رصيد فوري - كود 9821430012',
      paymentMethod: 'فوري (Fawry)',
      fawryRefCode: '9821430012',
      status: TransactionStatus.pending,
    ),
  ];

  double get commissionRate => _commissionRate;
  double get toktokBasePrice => _toktokBasePrice;
  double get toktokPerKm => _toktokPerKm;
  double get motoBasePrice => _motoBasePrice;
  double get motoPerKm => _motoPerKm;
  double get marsoulBasePrice => _marsoulBasePrice;
  double get marsoulPerKm => _marsoulPerKm;

  List<DriverProfile> get drivers => List.unmodifiable(_drivers);
  List<WalletTransaction> get pendingTopUps => List.unmodifiable(_pendingTopUps);

  int get totalCompletedTrips => 1248;
  double get totalCityGmv => 37400.0; // EGP
  double get totalCommissionCollected => totalCityGmv * _commissionRate;

  void updateCommissionRate(double newRate) {
    _commissionRate = newRate;
    notifyListeners();
  }

  void updateToktokPricing({required double base, required double perKm}) {
    _toktokBasePrice = base;
    _toktokPerKm = perKm;
    notifyListeners();
  }

  void updateMotoPricing({required double base, required double perKm}) {
    _motoBasePrice = base;
    _motoPerKm = perKm;
    notifyListeners();
  }

  void toggleDriverVerification(String driverId) {
    final index = _drivers.indexWhere((d) => d.id == driverId);
    if (index != -1) {
      final current = _drivers[index];
      _drivers[index] = current.copyWith(isVerified: !current.isVerified);
      notifyListeners();
    }
  }

  void approveTopUp(String transactionId) {
    final index = _pendingTopUps.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      _pendingTopUps.removeAt(index);
      notifyListeners();
    }
  }

  void rejectTopUp(String transactionId) {
    _pendingTopUps.removeWhere((t) => t.id == transactionId);
    notifyListeners();
  }
}
