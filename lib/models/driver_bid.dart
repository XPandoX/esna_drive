class DriverBid {
  final String bidId;
  final String driverId;
  final String driverName;
  final String vehicleType;
  final String vehiclePlate;
  final double rating;
  final int totalRides;
  final int etaMinutes;
  final double offeredPrice;
  final double distanceKm;
  final String avatarSeed;
  final bool isCounterOffer;

  const DriverBid({
    required this.bidId,
    required this.driverId,
    required this.driverName,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.rating,
    required this.totalRides,
    required this.etaMinutes,
    required this.offeredPrice,
    required this.distanceKm,
    required this.avatarSeed,
    this.isCounterOffer = false,
  });

  Map<String, dynamic> toJson() => {
        'bidId': bidId,
        'driverId': driverId,
        'driverName': driverName,
        'vehicleType': vehicleType,
        'vehiclePlate': vehiclePlate,
        'rating': rating,
        'totalRides': totalRides,
        'etaMinutes': etaMinutes,
        'offeredPrice': offeredPrice,
        'distanceKm': distanceKm,
        'avatarSeed': avatarSeed,
        'isCounterOffer': isCounterOffer,
      };

  factory DriverBid.fromJson(Map<String, dynamic> json) => DriverBid(
        bidId: json['bidId'],
        driverId: json['driverId'],
        driverName: json['driverName'],
        vehicleType: json['vehicleType'],
        vehiclePlate: json['vehiclePlate'],
        rating: (json['rating'] as num).toDouble(),
        totalRides: json['totalRides'] as int,
        etaMinutes: json['etaMinutes'] as int,
        offeredPrice: (json['offeredPrice'] as num).toDouble(),
        distanceKm: (json['distanceKm'] as num).toDouble(),
        avatarSeed: json['avatarSeed'] ?? 'driver',
        isCounterOffer: json['isCounterOffer'] ?? false,
      );
}
