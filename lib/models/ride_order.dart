import 'package:latlong2/latlong.dart';
import 'esna_place.dart';
import 'driver_bid.dart';

enum RideStatus {
  idle,
  searching,
  bidding,
  accepted,
  driverArrived,
  inProgress,
  completed,
  cancelled,
}

class CourierDetails {
  final String recipientPhone;
  final String itemName;
  final String payer; // 'الراسل', 'المستلم'
  final bool doorToDoor;
  final String qrDeliveryCode;

  const CourierDetails({
    required this.recipientPhone,
    required this.itemName,
    required this.payer,
    this.doorToDoor = false,
    required this.qrDeliveryCode,
  });

  Map<String, dynamic> toJson() => {
        'recipientPhone': recipientPhone,
        'itemName': itemName,
        'payer': payer,
        'doorToDoor': doorToDoor,
        'qrDeliveryCode': qrDeliveryCode,
      };

  factory CourierDetails.fromJson(Map<String, dynamic> json) => CourierDetails(
        recipientPhone: json['recipientPhone'],
        itemName: json['itemName'],
        payer: json['payer'],
        doorToDoor: json['doorToDoor'] ?? false,
        qrDeliveryCode: json['qrDeliveryCode'],
      );
}

class RideOrder {
  final String id;
  final String passengerId;
  final String passengerName;
  final String passengerPhone;
  final EsnaPlace pickupPlace;
  final EsnaPlace destinationPlace;
  final String categoryId;
  final double initialSuggestedPrice;
  final double passengerOfferedPrice;
  final double agreedPrice;
  final List<LatLng> polylinePoints;
  final double distanceKm;
  final double durationMinutes;
  final RideStatus status;
  final DriverBid? acceptedBid;
  final String paymentMethod;
  final CourierDetails? courierDetails;
  final DateTime createdAt;
  final DateTime? arrivedAt;

  const RideOrder({
    required this.id,
    required this.passengerId,
    required this.passengerName,
    required this.passengerPhone,
    required this.pickupPlace,
    required this.destinationPlace,
    required this.categoryId,
    required this.initialSuggestedPrice,
    required this.passengerOfferedPrice,
    required this.agreedPrice,
    required this.polylinePoints,
    required this.distanceKm,
    required this.durationMinutes,
    this.status = RideStatus.bidding,
    this.acceptedBid,
    this.paymentMethod = 'كاش',
    this.courierDetails,
    required this.createdAt,
    this.arrivedAt,
  });

  RideOrder copyWith({
    String? id,
    String? passengerId,
    String? passengerName,
    String? passengerPhone,
    EsnaPlace? pickupPlace,
    EsnaPlace? destinationPlace,
    String? categoryId,
    double? initialSuggestedPrice,
    double? passengerOfferedPrice,
    double? agreedPrice,
    List<LatLng>? polylinePoints,
    double? distanceKm,
    double? durationMinutes,
    RideStatus? status,
    DriverBid? acceptedBid,
    String? paymentMethod,
    CourierDetails? courierDetails,
    DateTime? createdAt,
    DateTime? arrivedAt,
  }) {
    return RideOrder(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      pickupPlace: pickupPlace ?? this.pickupPlace,
      destinationPlace: destinationPlace ?? this.destinationPlace,
      categoryId: categoryId ?? this.categoryId,
      initialSuggestedPrice: initialSuggestedPrice ?? this.initialSuggestedPrice,
      passengerOfferedPrice: passengerOfferedPrice ?? this.passengerOfferedPrice,
      agreedPrice: agreedPrice ?? this.agreedPrice,
      polylinePoints: polylinePoints ?? this.polylinePoints,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      acceptedBid: acceptedBid ?? this.acceptedBid,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      courierDetails: courierDetails ?? this.courierDetails,
      createdAt: createdAt ?? this.createdAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
    );
  }
}
