import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/public_apis_service.dart';
import '../../models/driver_bid.dart';
import '../../providers/ride_provider.dart';

class BiddingScreen extends StatelessWidget {
  const BiddingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, rideProv, child) {
        final ride = rideProv.currentRide;
        final bids = rideProv.incomingBids;

        return Scaffold(
          appBar: AppBar(
            title: const Text('عروض الكباتن المباشرة'),
            automaticallyImplyLeading: false,
            actions: [
              TextButton(
                onPressed: () => rideProv.cancelRide(),
                child: const Text('إلغاء الطلب', style: TextStyle(color: AppTheme.alertRed)),
              ),
            ],
          ),
          body: Column(
            children: [
              // 1. Radar Pulse Status Bar
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.primaryLime,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'طلبك معروض الآن على كباتن التوك توك والموتوسيكل بإسنا...',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Route summary
                    Row(
                      children: [
                        const Icon(Icons.circle, color: AppTheme.primaryLime, size: 10),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ride?.pickupPlace.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: AppTheme.textMuted, size: 14),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on, color: AppTheme.alertRed, size: 12),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ride?.destinationPlace.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppTheme.darkBorder, height: 20),

                    // Current Offer & Quick Increment
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('سعرك المعروض حالياً:', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            Row(
                              children: [
                                Text(
                                  '${rideProv.offeredPrice.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryLime,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text('ج.م', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.darkCard,
                                foregroundColor: AppTheme.primaryLime,
                                side: const BorderSide(color: AppTheme.primaryLime),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: () => rideProv.increaseOffer(5),
                              child: const Text('+5 ج.م للتشجيع', style: TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.darkCard,
                                foregroundColor: AppTheme.primaryLime,
                                side: const BorderSide(color: AppTheme.primaryLime),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: () => rideProv.increaseOffer(10),
                              child: const Text('+10 ج.م', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Incoming Driver Bids Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'العروض الواردة (${bids.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const Text(
                      'اختر السعر والكابتن الأنسب لك',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),

              // 3. Driver Bids List
              Expanded(
                child: bids.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.radar, size: 64, color: AppTheme.textMuted),
                            SizedBox(height: 14),
                            Text(
                              'جاري تلقي عروض الكباتن بالقرب منك...',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'الكباتن يرون مسار رحلتك في شوارع إسنا الآن',
                              style: TextStyle(color: AppTheme.textSubtle, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: bids.length,
                        itemBuilder: (context, index) {
                          final bid = bids[index];
                          return _buildDriverBidCard(context, bid, rideProv);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDriverBidCard(BuildContext context, DriverBid bid, RideProvider rideProv) {
    final avatarUrl = PublicApisService.getAvatarUrl(bid.avatarSeed);
    final isCounterOffer = bid.isCounterOffer;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCounterOffer ? AppTheme.warningOrange.withOpacity(0.6) : AppTheme.primaryLime,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.darkSurface,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.driverName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bid.vehicleType} • ${bid.vehiclePlate}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppTheme.warningOrange, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${bid.rating} (${bid.totalRides} مشوار)',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.timer_outlined, color: AppTheme.textMuted, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'يصل خلال ${bid.etaMinutes} دقائق',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${bid.offeredPrice.toInt()} ج.م',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isCounterOffer ? AppTheme.warningOrange : AppTheme.primaryLime,
                    ),
                  ),
                  if (isCounterOffer)
                    const Text(
                      'عرض مضاد (+5)',
                      style: TextStyle(color: AppTheme.warningOrange, fontSize: 10, fontWeight: FontWeight.bold),
                    )
                  else
                    const Text(
                      'نفس سعرك بالضبط',
                      style: TextStyle(color: AppTheme.primaryLime, fontSize: 10),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLime,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => rideProv.acceptBid(bid),
                  child: const Text('قبول العرض', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.alertRed,
                    side: const BorderSide(color: AppTheme.alertRed),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => rideProv.rejectBid(bid),
                  child: const Text('رفض'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
