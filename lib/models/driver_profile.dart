class DriverProfile {
  final String id;
  final String name;
  final String phone;
  final String vehicleType; // 'توك توك', 'موتوسيكل', 'تروسيكل'
  final String vehicleNumber; // Local Esna municipal registration number
  final bool isVerified;
  final double walletBalance;
  final double rating;
  final int totalRides;
  final String? nationalIdFront;
  final String? nationalIdBack;
  final String? licenseOrBill;
  final String? criminalRecord;
  final String? vehiclePhoto;
  final String? selfiePhoto;
  final String qrCodeData;

  const DriverProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.vehicleNumber,
    this.isVerified = false,
    this.walletBalance = 150.0, // Initial demo credit
    this.rating = 4.9,
    this.totalRides = 342,
    this.nationalIdFront,
    this.nationalIdBack,
    this.licenseOrBill,
    this.criminalRecord,
    this.vehiclePhoto,
    this.selfiePhoto,
    required this.qrCodeData,
  });

  DriverProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? vehicleType,
    String? vehicleNumber,
    bool? isVerified,
    double? walletBalance,
    double? rating,
    int? totalRides,
    String? nationalIdFront,
    String? nationalIdBack,
    String? licenseOrBill,
    String? criminalRecord,
    String? vehiclePhoto,
    String? selfiePhoto,
    String? qrCodeData,
  }) {
    return DriverProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      isVerified: isVerified ?? this.isVerified,
      walletBalance: walletBalance ?? this.walletBalance,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      nationalIdFront: nationalIdFront ?? this.nationalIdFront,
      nationalIdBack: nationalIdBack ?? this.nationalIdBack,
      licenseOrBill: licenseOrBill ?? this.licenseOrBill,
      criminalRecord: criminalRecord ?? this.criminalRecord,
      vehiclePhoto: vehiclePhoto ?? this.vehiclePhoto,
      selfiePhoto: selfiePhoto ?? this.selfiePhoto,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'vehicleType': vehicleType,
        'vehicleNumber': vehicleNumber,
        'isVerified': isVerified,
        'walletBalance': walletBalance,
        'rating': rating,
        'totalRides': totalRides,
        'qrCodeData': qrCodeData,
      };

  factory DriverProfile.fromJson(Map<String, dynamic> json) => DriverProfile(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        vehicleType: json['vehicleType'],
        vehicleNumber: json['vehicleNumber'],
        isVerified: json['isVerified'] ?? false,
        walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 150.0,
        rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
        totalRides: json['totalRides'] as int? ?? 100,
        qrCodeData: json['qrCodeData'] ?? 'ESNA-DRIVER-${json['id']}',
      );
}
