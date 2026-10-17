import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fare_calculator.dart';
import '../../providers/driver_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/esna_map_widget.dart';

class DriverActiveTripScreen extends StatelessWidget {
  const DriverActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<DriverProvider, WalletProvider, AdminProvider>(
      builder: (context, driverProv, walletProv, adminProv, child) {
        final trip = driverProv.activeDriverTrip;
        if (trip == null) return const SizedBox.shrink();

        final hasArrived = driverProv.hasArrivedAtPickup;
        final tripStarted = driverProv.tripStarted;

        final commission = FareCalculator.calculateCommission(
          trip.agreedPrice,
          adminProv.commissionRate,
        );

        return Scaffold(
          body: Stack(
            children: [
              // 1. Map View
              const Positioned.fill(
                child: EsnaMapWidget(showLandmarks: false),
              ),

              // 2. Top Status Header
              SafeArea(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: tripStarted
                        ? AppTheme.primaryGreen
                        : (hasArrived ? AppTheme.warningOrange : AppTheme.darkSurface.withOpacity(0.95)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tripStarted ? Icons.navigation : (hasArrived ? Icons.timer : Icons.directions_car),
                        color: tripStarted || hasArrived ? Colors.black : AppTheme.primaryLime,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tripStarted
                                  ? 'المشوار قيد التنفيذ'
                                  : (hasArrived ? 'أنت في نقطة الإقلال (انتظار الركاب)' : 'توجه لنقطة إقلال الراكب'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: tripStarted || hasArrived ? Colors.black : Colors.white,
                              ),
                            ),
                            Text(
                              tripStarted ? 'المقصد: ${trip.destinationPlace.name}' : 'نقطة الانطلاق: ${trip.pickupPlace.name}',
                              style: TextStyle(
                                fontSize: 11,
                                color: tripStarted || hasArrived ? Colors.black87 : AppTheme.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Bottom Driver Action Sheet
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Passenger & Fare Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.passengerName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                trip.passengerPhone,
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${trip.agreedPrice.toInt()} ج.م',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryLime,
                                ),
                              ),
                              Text(
                                'العمولة: $commission ج.م (${(adminProv.commissionRate * 100).toInt()}%)',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // If Marsoul Parcel: show recipient & verification details
                      if (trip.courierDetails != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.darkBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryLime, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'طرد: ${trip.courierDetails!.itemName} • هاتف المستلم: ${trip.courierDetails!.recipientPhone}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              if (trip.courierDetails!.doorToDoor)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('باب للباب', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 10)),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Progressive Trip Action Buttons
                      if (!hasArrived) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryLime),
                            onPressed: () {
                              final ok = walletProv.deductCommission(commission, trip.id);
                              if (!ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('رصيد محفظتك غير كافٍ لخصم العمولة، يرجى شحن المحفظة'),
                                  ),
                                );
                                return;
                              }
                              driverProv.markArrivedAtPickup();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.primaryGreen,
                                  content: Text('تم تأكيد الوصول وخصم عمولة المنصة ($commission ج.م)'),
                                ),
                              );
                            },
                            child: const Text('لقد وصلتُ لنقطة الإقلال'),
                          ),
                        ),
                      ] else if (!tripStarted) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                            onPressed: () {
                              driverProv.startTrip();
                            },
                            child: const Text('ركب العميل - بدء المشوار'),
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryLime),
                            onPressed: () {
                              driverProv.completeTrip();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.primaryGreen,
                                  content: Text(
                                    'اكتمل المشوار بنجاح! تم استلام الأجرة (${trip.agreedPrice.toInt()} ج.م) نقداً',
                                  ),
                                ),
                              );
                            },
                            child: Text('إنهاء المشوار واستلام الأجرة (${trip.agreedPrice.toInt()} ج.م)'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Cancel & Refund
                      TextButton(
                        onPressed: () {
                          if (hasArrived) {
                            walletProv.refundCommission(commission, trip.id, 'إلغاء الرحلة لعدم حضور الراكب');
                          }
                          driverProv.cancelActiveTrip();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم إلغاء الرحلة واسترداد العمولة')),
                          );
                        },
                        child: const Text('إلغاء المشوار لعدم حضور الراكب', style: TextStyle(color: AppTheme.alertRed, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
