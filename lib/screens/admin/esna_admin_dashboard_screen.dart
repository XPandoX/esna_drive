import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/role_drawer.dart';

class EsnaAdminDashboardScreen extends StatelessWidget {
  const EsnaAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AdminProvider, WalletProvider>(
      builder: (context, adminProv, walletProv, child) {
        return Scaffold(
          drawer: const RoleDrawer(),
          appBar: AppBar(
            title: const Text('لوحة إدارة إسنا درايف المحلية'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. City Metrics Summary
                Row(
                  children: [
                    _buildStatCard(
                      'إجمالي الرحلات',
                      '${adminProv.totalCompletedTrips}',
                      Icons.trip_origin,
                      AppTheme.primaryLime,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      'حجم المعاملات (GMV)',
                      '${adminProv.totalCityGmv.toInt()} ج.م',
                      Icons.account_balance,
                      AppTheme.infoBlue,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      'العمولة المحصلة',
                      '${adminProv.totalCommissionCollected.toInt()} ج.م',
                      Icons.savings_outlined,
                      AppTheme.primaryGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Commission Rate Setting
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.darkBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'نسبة عمولة المنصة على المشاوير:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            '${(adminProv.commissionRate * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: AppTheme.primaryLime,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: adminProv.commissionRate,
                        min: 0.03, // 3%
                        max: 0.15, // 15%
                        divisions: 12,
                        activeColor: AppTheme.primaryLime,
                        onChanged: (val) => adminProv.updateCommissionRate(val),
                      ),
                      const Text(
                        'نسبة inDrive مصر القياسية هي 7% فقط، لدعم سائقي التوك توك والموتوسيكل',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Pending Wallet Top-Ups
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'طلبات شحن المحافظ المعلقة:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '${adminProv.pendingTopUps.length} طلبات',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (adminProv.pendingTopUps.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: const Center(
                      child: Text(
                        'لا توجد طلبات شحن معلقة حالياً - جميع المحافظ محدثة',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ),
                  )
                else
                  ...adminProv.pendingTopUps.map((topUp) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.primaryLime.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.receipt, color: AppTheme.primaryLime),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topUp.description,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'المبلغ: ${topUp.amount} ج.م • طريقة: ${topUp.paymentMethod}',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            onPressed: () {
                              adminProv.approveTopUp(topUp.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppTheme.primaryGreen,
                                  content: Text('تم اعتماد الشحن وإضافة الرصيد بنجاح'),
                                ),
                              );
                            },
                            child: const Text('موافقة فورية', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 20),

                // 4. Manage Drivers & Capacities
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'سجل الكباتن والمركبات المعتمدة بإسنا:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '${adminProv.drivers.length} كباتن',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                ...adminProv.drivers.map((driver) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.darkSurface,
                          child: Icon(
                            driver.vehicleType == 'توك توك' ? Icons.electric_rickshaw : Icons.two_wheeler,
                            color: AppTheme.primaryLime,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    driver.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const SizedBox(width: 6),
                                  if (driver.isVerified)
                                    const Icon(Icons.verified, color: AppTheme.primaryGreen, size: 16),
                                ],
                              ),
                              Text(
                                '${driver.vehicleType} • لوحة/رقم: ${driver.vehicleNumber}',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              ),
                              Text(
                                'التقييم: ${driver.rating} • الرحلات: ${driver.totalRides}',
                                style: const TextStyle(color: AppTheme.textSubtle, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: driver.isVerified,
                          activeColor: AppTheme.primaryGreen,
                          onChanged: (_) {
                            adminProv.toggleDriverVerification(driver.id);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
