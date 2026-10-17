import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class SosDialog extends StatelessWidget {
  final String rideId;

  const SosDialog({super.key, required this.rideId});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: const [
          Icon(Icons.shield, color: AppTheme.alertRed, size: 28),
          SizedBox(width: 10),
          Text(
            'درع الأمان والطوارئ (SOS)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'سلامتك هي الأولوية القصوى دائماً. يمكنك الاتصال الفوري بخدمات الطوارئ الرسمية أو مشاركة مسار رحلتك في إسنا:',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 18),
          _buildEmergencyButton(
            context,
            title: 'شرطة النجدة (122)',
            subtitle: 'طوارئ أمنية فورية',
            color: AppTheme.alertRed,
            icon: Icons.local_police,
            onTap: () => _makePhoneCall(AppConstants.policeEmergency),
          ),
          const SizedBox(height: 10),
          _buildEmergencyButton(
            context,
            title: 'الإسعاف المصري (123)',
            subtitle: 'طوارئ طبية وحوادث',
            color: AppTheme.warningOrange,
            icon: Icons.medical_services,
            onTap: () => _makePhoneCall(AppConstants.ambulanceEmergency),
          ),
          const SizedBox(height: 10),
          _buildEmergencyButton(
            context,
            title: 'مشاركة مسار الرحلة الحية',
            subtitle: 'إرسال رابط التتبع للأهل أو الأصدقاء',
            color: AppTheme.primaryLime,
            textColor: Colors.black,
            icon: Icons.share_location,
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.primaryGreen,
                  content: Text(
                    'تم نسخ رابط التتبع المباشر لرحلة إسنا #$rideId إلى الحافظة',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: AppTheme.textMuted)),
        ),
      ],
    );
  }

  Widget _buildEmergencyButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    Color textColor = Colors.white,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textColor == Colors.black ? Colors.white : color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
