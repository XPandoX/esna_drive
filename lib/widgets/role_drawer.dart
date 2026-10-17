import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/services/public_apis_service.dart';

class RoleDrawer extends StatelessWidget {
  const RoleDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.darkBg,
      child: Consumer2<AuthProvider, WalletProvider>(
        builder: (context, authProv, walletProv, child) {
          final avatarUrl = PublicApisService.getAvatarUrl(authProv.userId);

          return Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 24, left: 20, right: 20),
                decoration: const BoxDecoration(
                  color: AppTheme.darkSurface,
                  border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppTheme.darkCard,
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProv.userName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authProv.phoneNumber ?? '01012345678',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLime.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getRoleLabel(authProv.currentRole),
                                  style: const TextStyle(
                                    color: AppTheme.primaryLime,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Wallet Balance Quick View
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.darkBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'رصيد المحفظة:',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                          Text(
                            '${walletProv.balance.toStringAsFixed(1)} ج.م',
                            style: const TextStyle(
                              color: AppTheme.primaryLime,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Mode Switch Section
              const Padding(
                padding: EdgeInsets.only(top: 18, bottom: 8, right: 20, left: 20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'تبديل الوضع (Role Switching)',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              _buildDrawerItem(
                context,
                title: 'وضع الراكب والطرود',
                subtitle: 'طلب توك توك، موتوسيكل، مرسول إسنا',
                icon: Icons.person_pin_circle_outlined,
                isSelected: authProv.currentRole == AppRole.passenger,
                onTap: () {
                  authProv.switchRole(AppRole.passenger);
                  Navigator.pop(context);
                },
              ),

              _buildDrawerItem(
                context,
                title: 'وضع الكابتن والمندوب',
                subtitle: 'رادار الطلبات، تقديم العروض، المحفظة',
                icon: Icons.two_wheeler_outlined,
                isSelected: authProv.currentRole == AppRole.driver,
                onTap: () {
                  authProv.switchRole(AppRole.driver);
                  Navigator.pop(context);
                },
              ),

              _buildDrawerItem(
                context,
                title: 'لوحة تحكم إدارة إسنا',
                subtitle: 'اعتماد الكباتن، التسعير، المحافظ',
                icon: Icons.admin_panel_settings_outlined,
                isSelected: authProv.currentRole == AppRole.admin,
                onTap: () {
                  authProv.switchRole(AppRole.admin);
                  Navigator.pop(context);
                },
              ),

              const Divider(color: AppTheme.darkBorder, height: 32),

              // App Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    Icon(Icons.location_city, color: AppTheme.primaryLime, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'إسنا - محافظة الأقصر (مصر)',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Logout / Reset
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      authProv.logout();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('تسجيل الخروج'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getRoleLabel(AppRole role) {
    switch (role) {
      case AppRole.passenger:
        return 'وضع الراكب';
      case AppRole.driver:
        return 'وضع الكابتن';
      case AppRole.admin:
        return 'إدارة النظام';
    }
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryLime.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppTheme.primaryLime : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryLime : AppTheme.textMuted,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isSelected ? AppTheme.primaryLime : Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppTheme.primaryLime, size: 18)
            : null,
        onTap: onTap,
      ),
    );
  }
}
