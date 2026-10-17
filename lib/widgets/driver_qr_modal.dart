import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/services/public_apis_service.dart';
import '../models/driver_bid.dart';

class DriverQrModal extends StatelessWidget {
  final DriverBid bid;

  const DriverQrModal({super.key, required this.bid});

  @override
  Widget build(BuildContext context) {
    final qrData = 'ESNADRIVE:CAPTAIN:${bid.driverId}:${bid.vehiclePlate}:SAFETY-VERIFIED';
    final qrUrl = PublicApisService.getQrCodeUrl(qrData, size: 260);
    final avatarUrl = PublicApisService.getAvatarUrl(bid.avatarSeed);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppTheme.darkBorder,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.darkCard,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            bid.driverName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: AppTheme.primaryLime, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bid.vehicleType} • لوحة/رقم: ${bid.vehiclePlate}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLime.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppTheme.primaryLime, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      bid.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryLime,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'بطاقة التحقق الرقمية (EsnaDrive ID)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          const Text(
            'امسح الرمز للتأكد من هوية المركبة واعتماد الكابتن بالوحدة المحلية بإسنا',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.network(
              qrUrl,
              width: 180,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 180,
                height: 180,
                child: Center(
                  child: Icon(Icons.qr_code_2, size: 80, color: Colors.black87),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق البطاقة'),
            ),
          ),
        ],
      ),
    );
  }
}
