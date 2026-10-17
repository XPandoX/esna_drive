import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/esna_place.dart';
import '../models/ride_order.dart';
import '../models/driver_bid.dart';
import '../core/constants/app_constants.dart';
import '../core/services/public_apis_service.dart';
import '../core/utils/fare_calculator.dart';

class ChatMessage {
  final String sender; // 'passenger', 'driver'
  final String text;
  final DateTime time;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
  });
}

class RideProvider extends ChangeNotifier {
  EsnaPlace _pickup = const EsnaPlace(
    id: 'khnum_temple',
    name: 'معبد إسنا (معبد خنوم)',
    category: 'معالم إسنا',
    location: LatLng(25.2934, 32.5562),
    address: 'وسط البلد - شارع المعبد',
  );

  EsnaPlace _destination = const EsnaPlace(
    id: 'tiba_hospital',
    name: 'مستشفى طيبة التخصصي',
    category: 'مستشفيات',
    location: LatLng(25.2845, 32.5480),
    address: 'طريق طيبة الرئيسي',
  );

  String _selectedCategory = 'toktok';
  double _suggestedPrice = 20.0;
  double _offeredPrice = 20.0;
  String _paymentMethod = 'كاش';
  bool _isDoorToDoor = false;

  // Courier specific data
  String _courierRecipientPhone = '';
  String _courierItemDescription = '';
  String _courierPayer = 'الراسل';

  // Active Ride & Route
  RideOrder? _currentRide;
  List<LatLng> _currentRoutePoints = [];
  double _currentDistanceKm = 1.8;
  double _currentDurationMin = 5.5;
  bool _isLoadingRoute = false;

  // Bids
  final List<DriverBid> _incomingBids = [];
  Timer? _bidsTimer;
  Timer? _waitTimer;
  Timer? _animationTimer;

  // Active ride tracking
  int _waitingSecondsLeft = 300; // 5 minutes free wait
  LatLng? _driverCurrentPosition;
  int _currentPolylineIndex = 0;

  // In-app chat
  final List<ChatMessage> _chatMessages = [];

  // Getters
  EsnaPlace get pickup => _pickup;
  EsnaPlace get destination => _destination;
  String get selectedCategory => _selectedCategory;
  double get suggestedPrice => _suggestedPrice;
  double get offeredPrice => _offeredPrice;
  String get paymentMethod => _paymentMethod;
  bool get isDoorToDoor => _isDoorToDoor;
  String get courierRecipientPhone => _courierRecipientPhone;
  String get courierItemDescription => _courierItemDescription;
  String get courierPayer => _courierPayer;

  RideOrder? get currentRide => _currentRide;
  List<LatLng> get currentRoutePoints => _currentRoutePoints;
  double get currentDistanceKm => _currentDistanceKm;
  double get currentDurationMin => _currentDurationMin;
  bool get isLoadingRoute => _isLoadingRoute;
  List<DriverBid> get incomingBids => List.unmodifiable(_incomingBids);
  int get waitingSecondsLeft => _waitingSecondsLeft;
  LatLng? get driverCurrentPosition => _driverCurrentPosition;
  List<ChatMessage> get chatMessages => List.unmodifiable(_chatMessages);

  RideProvider() {
    updateRoute();
  }

  void setPickup(EsnaPlace place) {
    _pickup = place;
    notifyListeners();
    updateRoute();
  }

  void setDestination(EsnaPlace place) {
    _destination = place;
    notifyListeners();
    updateRoute();
  }

  void setCategory(String categoryId, {bool isExtremeHeat = false}) {
    _selectedCategory = categoryId;
    _recalculateFare(isExtremeHeat: isExtremeHeat);
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setDoorToDoor(bool val, {bool isExtremeHeat = false}) {
    _isDoorToDoor = val;
    _recalculateFare(isExtremeHeat: isExtremeHeat);
    notifyListeners();
  }

  void setCourierDetails({
    required String recipientPhone,
    required String itemDescription,
    required String payer,
  }) {
    _courierRecipientPhone = recipientPhone;
    _courierItemDescription = itemDescription;
    _courierPayer = payer;
    notifyListeners();
  }

  void increaseOffer(double amount) {
    _offeredPrice += amount;
    if (_currentRide != null) {
      _currentRide = _currentRide!.copyWith(passengerOfferedPrice: _offeredPrice);
    }
    notifyListeners();
  }

  void setCustomOffer(double amount) {
    _offeredPrice = amount;
    if (_currentRide != null) {
      _currentRide = _currentRide!.copyWith(passengerOfferedPrice: _offeredPrice);
    }
    notifyListeners();
  }

  Future<void> updateRoute({bool isExtremeHeat = false}) async {
    _isLoadingRoute = true;
    notifyListeners();

    try {
      final route = await PublicApisService.getDrivingRoute(_pickup.location, _destination.location);
      _currentRoutePoints = route.polylinePoints;
      _currentDistanceKm = route.distanceKm;
      _currentDurationMin = route.durationMinutes;
      _recalculateFare(isExtremeHeat: isExtremeHeat);
    } catch (_) {
      // Fallback
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
  }

  void _recalculateFare({bool isExtremeHeat = false}) {
    _suggestedPrice = FareCalculator.calculateSuggestedFare(
      categoryId: _selectedCategory,
      distanceKm: _currentDistanceKm,
      isDoorToDoor: _isDoorToDoor,
      isExtremeHeat: isExtremeHeat,
    );
    _offeredPrice = _suggestedPrice;
  }

  // --- Live Bidding Flow ---

  void requestRide({required String passengerName, required String passengerPhone}) {
    final rideId = 'RIDE-${DateTime.now().millisecondsSinceEpoch % 100000}';
    CourierDetails? courier;

    if (_selectedCategory == 'marsoul') {
      courier = CourierDetails(
        recipientPhone: _courierRecipientPhone.isNotEmpty ? _courierRecipientPhone : '010XXXXXXXX',
        itemName: _courierItemDescription.isNotEmpty ? _courierItemDescription : 'طلب توصيل من إسنا',
        payer: _courierPayer,
        doorToDoor: _isDoorToDoor,
        qrDeliveryCode: 'ESNA-PARCEL-$rideId',
      );
    }

    _currentRide = RideOrder(
      id: rideId,
      passengerId: 'p_current',
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      pickupPlace: _pickup,
      destinationPlace: _destination,
      categoryId: _selectedCategory,
      initialSuggestedPrice: _suggestedPrice,
      passengerOfferedPrice: _offeredPrice,
      agreedPrice: _offeredPrice,
      polylinePoints: _currentRoutePoints,
      distanceKm: _currentDistanceKm,
      durationMinutes: _currentDurationMin,
      status: RideStatus.bidding,
      paymentMethod: _paymentMethod,
      courierDetails: courier,
      createdAt: DateTime.now(),
    );

    _incomingBids.clear();
    _chatMessages.clear();
    notifyListeners();

    _startSimulatedBidsStream();
  }

  void _startSimulatedBidsStream() {
    _bidsTimer?.cancel();
    int count = 0;

    // Stream realistic Esna drivers inDrive style
    final candidateDrivers = [
      DriverBid(
        bidId: 'bid_1',
        driverId: 'd_1',
        driverName: 'الأسطى محمود - توك توك رقم 418',
        vehicleType: _selectedCategory == 'motorcycle' ? 'دايون 4' : 'توك توك باجاج',
        vehiclePlate: 'إسنا - 418',
        rating: 4.9,
        totalRides: 480,
        etaMinutes: 2,
        offeredPrice: _offeredPrice, // Exact passenger price
        distanceKm: 0.4,
        avatarSeed: 'captain_mahmoud',
        isCounterOffer: false,
      ),
      DriverBid(
        bidId: 'bid_2',
        driverId: 'd_2',
        driverName: 'كابتن أحمد النمساوي',
        vehicleType: _selectedCategory == 'motorcycle' ? 'هوجان F250' : 'توك توك تيفي إس',
        vehiclePlate: 'إسنا - 902',
        rating: 4.85,
        totalRides: 310,
        etaMinutes: 3,
        offeredPrice: _offeredPrice + 5.0, // Counter offer +5
        distanceKm: 0.7,
        avatarSeed: 'captain_ahmed',
        isCounterOffer: true,
      ),
      DriverBid(
        bidId: 'bid_3',
        driverId: 'd_3',
        driverName: 'الأسطى سيد أبو حجاج',
        vehicleType: _selectedCategory == 'motorcycle' ? 'بوكسر 150' : 'توك توك ركشة',
        vehiclePlate: 'إسنا - 155',
        rating: 4.95,
        totalRides: 620,
        etaMinutes: 4,
        offeredPrice: _offeredPrice + 10.0, // Counter offer +10
        distanceKm: 1.1,
        avatarSeed: 'captain_sayed',
        isCounterOffer: true,
      ),
    ];

    _bidsTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (count < candidateDrivers.length && _currentRide?.status == RideStatus.bidding) {
        _incomingBids.insert(0, candidateDrivers[count]);
        count++;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void acceptBid(DriverBid bid) {
    _bidsTimer?.cancel();
    if (_currentRide != null) {
      _currentRide = _currentRide!.copyWith(
        status: RideStatus.accepted,
        acceptedBid: bid,
        agreedPrice: bid.offeredPrice,
      );
      _driverCurrentPosition = _pickup.location;
      notifyListeners();

      _startActiveRideSimulation();
    }
  }

  void rejectBid(DriverBid bid) {
    _incomingBids.removeWhere((b) => b.bidId == bid.bidId);
    notifyListeners();
  }

  void _startActiveRideSimulation() {
    _waitingSecondsLeft = 300;
    _currentPolylineIndex = 0;

    // Simulate driver arrival after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (_currentRide != null && _currentRide!.status == RideStatus.accepted) {
        _currentRide = _currentRide!.copyWith(
          status: RideStatus.driverArrived,
          arrivedAt: DateTime.now(),
        );
        notifyListeners();

        // Start 5-minute free waiting countdown
        _startWaitingTimer();

        // Simulate start trip after 5 more seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (_currentRide != null && _currentRide!.status == RideStatus.driverArrived) {
            startTripInProgress();
          }
        });
      }
    });
  }

  void _startWaitingTimer() {
    _waitTimer?.cancel();
    _waitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_waitingSecondsLeft > 0 && _currentRide?.status == RideStatus.driverArrived) {
        _waitingSecondsLeft--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void startTripInProgress() {
    _waitTimer?.cancel();
    if (_currentRide != null) {
      _currentRide = _currentRide!.copyWith(status: RideStatus.inProgress);
      notifyListeners();

      // Animate movement along polyline
      _startMovementAnimation();
    }
  }

  void _startMovementAnimation() {
    _animationTimer?.cancel();
    if (_currentRoutePoints.isEmpty) return;

    _animationTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (_currentRide?.status == RideStatus.inProgress && _currentPolylineIndex < _currentRoutePoints.length) {
        _driverCurrentPosition = _currentRoutePoints[_currentPolylineIndex];
        _currentPolylineIndex++;
        notifyListeners();
      } else {
        timer.cancel();
        // Trip completed
        completeRide();
      }
    });
  }

  void completeRide() {
    _animationTimer?.cancel();
    _waitTimer?.cancel();
    if (_currentRide != null) {
      _currentRide = _currentRide!.copyWith(status: RideStatus.completed);
      notifyListeners();
    }
  }

  void cancelRide() {
    _bidsTimer?.cancel();
    _waitTimer?.cancel();
    _animationTimer?.cancel();
    if (_currentRide != null) {
      _currentRide = _currentRide!.copyWith(status: RideStatus.cancelled);
      notifyListeners();
    }
    Future.delayed(const Duration(milliseconds: 600), () {
      _currentRide = null;
      _incomingBids.clear();
      notifyListeners();
    });
  }

  void resetToNewRide() {
    _bidsTimer?.cancel();
    _waitTimer?.cancel();
    _animationTimer?.cancel();
    _currentRide = null;
    _incomingBids.clear();
    _chatMessages.clear();
    _waitingSecondsLeft = 300;
    notifyListeners();
  }

  // --- In-App Chat Simulation ---

  void sendChatMessage(String text) {
    if (text.trim().isEmpty) return;
    _chatMessages.add(ChatMessage(
      sender: 'passenger',
      text: text.trim(),
      time: DateTime.now(),
    ));
    notifyListeners();

    // Auto simulated captain reply
    Future.delayed(const Duration(milliseconds: 1200), () {
      final autoReplies = [
        'تمام يا فندم، أنا واصل لحضرتك في أقل من دقيقة.',
        'واقف منتظر حضرتك أمام البوابة.',
        'مساء الخير، مشغل التكييف/الموسيقى وجاهز للرحلة.',
      ];
      final reply = autoReplies[_chatMessages.length % autoReplies.length];
      _chatMessages.add(ChatMessage(
        sender: 'driver',
        text: reply,
        time: DateTime.now(),
      ));
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _bidsTimer?.cancel();
    _waitTimer?.cancel();
    _animationTimer?.cancel();
    super.dispose();
  }
}
