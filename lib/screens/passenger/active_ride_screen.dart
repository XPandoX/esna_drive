import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/public_apis_service.dart';
import '../../models/ride_order.dart';
import '../../providers/ride_provider.dart';
import '../../widgets/esna_map_widget.dart';
import '../../widgets/driver_qr_modal.dart';
import '../../widgets/sos_dialog.dart';
import '../../widgets/fare_rules_dialog.dart';

class ActiveRideScreen extends StatelessWidget {
  const ActiveRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, rideProv, child) {
        final ride = rideProv.currentRide;
        if (ride == null) return const SizedBox.shrink();

        final bid = ride.acceptedBid;
        final avatarUrl = PublicApisService.getAvatarUrl(bid?.avatarSeed ?? 'driver');
        final isArrived = ride.status == RideStatus.driverArrived;
        final isInProgress = ride.status == RideStatus.inProgress;
        final isCompleted = ride.status == RideStatus.completed;

        final minutes = (rideProv.waitingSecondsLeft ~/ 60).toString().padLeft(2, '0');
        final seconds = (rideProv.waitingSecondsLeft % 60).toString().padLeft(2, '0');

        return Scaffold(
          body: Stack(
            children: [
              // 1. Live Interactive Map with moving vehicle
              Positioned.fill(
                child: EsnaMapWidget(showLandmarks: false),
              ),

              // 2. Top Status Alert
              SafeArea(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.primaryGreen
                        : (isArrived ? AppTheme.warningOrange : AppTheme.darkSurface.withOpacity(0.95)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCompleted ? Colors.transparent : AppTheme.darkBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle
                            : (isInProgress ? Icons.navigation : (isArrived ? Icons.timer : Icons.directions_bike)),
                        color: isCompleted || isArrived ? Colors.black : AppTheme.primaryLime,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getStatusTitle(ride.status),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isCompleted || isArrived ? Colors.black : Colors.white,
                              ),
                            ),
                            Text(
                              isArrived
                                  ? 'وقت الانتظار المجاني المتبقي: $minutes:$seconds'
                                  : _getStatusSubtitle(ride.status, ride.destinationPlace.name),
                              style: TextStyle(
                                fontSize: 11,
                                color: isCompleted || isArrived ? Colors.black87 : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // SOS Shield Button
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => SosDialog(rideId: ride.id),
                          );
                        },
                        icon: const Icon(Icons.shield, color: AppTheme.alertRed, size: 28),
                        tooltip: 'درع الأمان (SOS)',
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Bottom Driver & Safety Panel
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                      // Driver Info
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
                                        bid?.driverName ?? 'كابتن إسنا',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified, color: AppTheme.primaryLime, size: 16),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${bid?.vehicleType ?? 'مركبة'} • رقم: ${bid?.vehiclePlate ?? 'إسنا'}',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${ride.agreedPrice.toInt()} ج.م',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryLime,
                                ),
                              ),
                              Text(
                                ride.paymentMethod,
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Safety & Communication Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionCircle(
                            icon: Icons.qr_code_2,
                            label: 'بطاقة الكابتن',
                            color: AppTheme.primaryLime,
                            onTap: () {
                              if (bid != null) {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => DriverQrModal(bid: bid),
                                );
                              }
                            },
                          ),
                          _buildActionCircle(
                            icon: Icons.chat_bubble_outline,
                            label: 'دردشة حية',
                            color: Colors.white,
                            onTap: () => _openChatSheet(context, rideProv),
                          ),
                          _buildActionCircle(
                            icon: Icons.phone_outlined,
                            label: 'اتصال مقنّع',
                            color: Colors.white,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppTheme.darkCard,
                                  content: Text(
                                    'مكالمة آمنة: تم تشفير رقم هاتفك الشخصي لحماية خصوصيتك وفق ميثاق inDrive',
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildActionCircle(
                            icon: Icons.handshake_outlined,
                            label: 'ميثاق السعر',
                            color: Colors.white,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => const FareRulesDialog(),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Bottom Main Action (Complete or Cancel)
                      if (isCompleted) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _showRatingDialog(context, rideProv);
                            },
                            child: const Text('تقييم الكابتن وإنهاء المشوار'),
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.alertRed,
                              side: const BorderSide(color: AppTheme.alertRed),
                            ),
                            onPressed: () => rideProv.cancelRide(),
                            child: const Text('إلغاء الرحلة'),
                          ),
                        ),
                      ],
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

  String _getStatusTitle(RideStatus status) {
    switch (status) {
      case RideStatus.accepted:
        return 'الكابتن في الطريق إليك';
      case RideStatus.driverArrived:
        return 'وصل الكابتن لنقطة الإقلال!';
      case RideStatus.inProgress:
        return 'الرحلة قيد التنفيذ الآن';
      case RideStatus.completed:
        return 'وصلت إلى وجهتك بحمد الله';
      default:
        return 'تتبع الرحلة في إسنا';
    }
  }

  String _getStatusSubtitle(RideStatus status, String destinationName) {
    switch (status) {
      case RideStatus.accepted:
        return 'يتحرك نحوك الآن في شوارع إسنا';
      case RideStatus.inProgress:
        return 'في الطريق إلى: $destinationName';
      case RideStatus.completed:
        return 'نتمنى لك يوماً سعيداً في مدينة إسنا';
      default:
        return '';
    }
  }

  Widget _buildActionCircle({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  void _openChatSheet(BuildContext context, RideProvider rideProv) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Consumer<RideProvider>(
          builder: (context, prov, child) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: 420,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.darkBorder,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'دردشة سريعة مع الكابتن',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const Divider(color: AppTheme.darkBorder),
                    // Quick Reply Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'أنا في انتظارك',
                          'أمام البوابة الرئيسية',
                          'معايا طرد خفيف',
                          'تمام يا كابتن',
                        ].map((txt) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: ActionChip(
                              label: Text(txt),
                              backgroundColor: AppTheme.darkCard,
                              labelStyle: const TextStyle(fontSize: 11, color: AppTheme.primaryLime),
                              onPressed: () => prov.sendChatMessage(txt),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Messages List
                    Expanded(
                      child: prov.chatMessages.isEmpty
                          ? const Center(
                              child: Text(
                                'ابدأ محادثة فورية لتنسيق نقطة الركوب بإسنا',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                            )
                          : ListView.builder(
                              itemCount: prov.chatMessages.length,
                              itemBuilder: (context, index) {
                                final msg = prov.chatMessages[index];
                                final isMe = msg.sender == 'passenger';
                                return Align(
                                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isMe ? AppTheme.primaryLime : AppTheme.darkCard,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      msg.text,
                                      style: TextStyle(
                                        color: isMe ? Colors.black : Colors.white,
                                        fontSize: 13,
                                        fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    // Input Bar
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: 'اكتب رسالة...',
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: AppTheme.primaryLime),
                          onPressed: () {
                            prov.sendChatMessage(controller.text);
                            controller.clear();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context, RideProvider rideProv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تقييم الكابتن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'كيف كانت تجربتك في هذا المشوار بمدينة إسنا؟',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return const Icon(Icons.star, color: AppTheme.warningOrange, size: 32);
              }),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                rideProv.resetToNewRide();
              },
              child: const Text('إرسال التقييم والعودة للرئيسية'),
            ),
          ),
        ],
      ),
    );
  }
}
