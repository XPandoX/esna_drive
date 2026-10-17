import 'package:flutter/foundation.dart';
import '../models/driver_profile.dart';
import '../models/ride_order.dart';
import '../core/services/public_apis_service.dart';

class DriverProvider extends ChangeNotifier {
  DriverProfile _profile = const DriverProfile(
    id: 'driver_current',
    name: 'الأسطى محمود عبد الرازق',
    phone: '01012345678',
    vehicleType: 'توك توك',
    vehicleNumber: 'إسنا - 418',
    isVerified: true,
    walletBalance: 150.0,
    rating: 4.95,
    totalRides: 512,
    qrCodeData: 'ESNA-DRIVER-MAHMOUD-418',
  );

  bool _isOnline = true;
  RideOrder? _activeDriverTrip;
  bool _hasArrivedAtPickup = false;
  bool _tripStarted = false;

  DriverProfile get profile => _profile;
  bool get isOnline => _isOnline;
  RideOrder? get activeDriverTrip => _activeDriverTrip;
  bool get hasArrivedAtPickup => _hasArrivedAtPickup;
  bool get tripStarted => _tripStarted;

  String get driverQrUrl => PublicApisService.getQrCodeUrl(_profile.qrCodeData, size: 240);
  String get driverAvatarUrl => PublicApisService.getAvatarUrl(_profile.id);

  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String phone,
    required String vehicleType,
    required String vehicleNumber,
    String? idFront,
    String? idBack,
    String? license,
    String? criminalRecord,
    String? vehiclePhoto,
    String? selfie,
  }) {
    _profile = _profile.copyWith(
      name: name,
      phone: phone,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      nationalIdFront: idFront ?? _profile.nationalIdFront,
      nationalIdBack: idBack ?? _profile.nationalIdBack,
      licenseOrBill: license ?? _profile.licenseOrBill,
      criminalRecord: criminalRecord ?? _profile.criminalRecord,
      vehiclePhoto: vehiclePhoto ?? _profile.vehiclePhoto,
      selfiePhoto: selfie ?? _profile.selfiePhoto,
      qrCodeData: 'ESNA-${vehicleType.toUpperCase()}-$vehicleNumber-${DateTime.now().millisecondsSinceEpoch}',
      isVerified: true, // Auto-verified in demo
    );
    notifyListeners();
  }

  void acceptRide(RideOrder ride, double agreedPrice) {
    _activeDriverTrip = ride.copyWith(
      status: RideStatus.accepted,
      agreedPrice: agreedPrice,
    );
    _hasArrivedAtPickup = false;
    _tripStarted = false;
    notifyListeners();
  }

  void markArrivedAtPickup() {
    _hasArrivedAtPickup = true;
    if (_activeDriverTrip != null) {
      _activeDriverTrip = _activeDriverTrip!.copyWith(
        status: RideStatus.driverArrived,
        arrivedAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  void startTrip() {
    _tripStarted = true;
    if (_activeDriverTrip != null) {
      _activeDriverTrip = _activeDriverTrip!.copyWith(
        status: RideStatus.inProgress,
      );
    }
    notifyListeners();
  }

  void completeTrip() {
    if (_activeDriverTrip != null) {
      _profile = _profile.copyWith(
        totalRides: _profile.totalRides + 1,
      );
      _activeDriverTrip = _activeDriverTrip!.copyWith(
        status: RideStatus.completed,
      );
    }
    _activeDriverTrip = null;
    _hasArrivedAtPickup = false;
    _tripStarted = false;
    notifyListeners();
  }

  void cancelActiveTrip() {
    _activeDriverTrip = null;
    _hasArrivedAtPickup = false;
    _tripStarted = false;
    notifyListeners();
  }
}
