import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/wallet_transaction.dart';
import '../../providers/wallet_provider.dart';

class DriverWalletScreen extends StatefulWidget {
  const DriverWalletScreen({super.key});

  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen> {
  final _amountController = TextEditingController(text: '50');
  String _selectedMethod = 'فوري'; // 'فوري', 'فودافون كاش', 'إنستا باي'

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProv, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('محفظة الكابتن والعمولة'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Balance Card (inDrive Style)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E2812), Color(0xFF121212)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.primaryLime.withOpacity(0.4), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('رصيد المحفظة المتاح', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                          Icon(Icons.account_balance_wallet, color: AppTheme.primaryLime, size: 24),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            walletProv.balance.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryLime,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Text('ج.م', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'عمولة المنصة: 7% فقط تُخصم تلقائياً عند الوصول لنقطة الإقلال وتُسترد إذا أُلغيت الرحلة',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Top-Up Section (inDrive Egypt rules)
                const Text(
                  'شحن رصيد المحفظة (Top-Up)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                // Method Selector Tabs
                Row(
                  children: [
                    _buildMethodTab('فوري', 'حد أدنى 40 ج.م', Icons.receipt_long),
                    const SizedBox(width: 8),
                    _buildMethodTab('فودافون كاش', '60 - 1600 ج.م', Icons.phone_android),
                    const SizedBox(width: 8),
                    _buildMethodTab('إنستا باي', 'فوري ومباشر', Icons.payment),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount Input
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'مبلغ الشحن بالجنيه المصري',
                    suffixText: 'ج.م',
                    prefixIcon: const Icon(Icons.monetization_on_outlined, color: AppTheme.primaryLime),
                    helperText: _selectedMethod == 'فوري'
                        ? 'الحد الأدنى للشحن عبر فوري هو 40 ج.م'
                        : 'الحد الأدنى 60 ج.م والحد الأقصى 1600 ج.م',
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Amount Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [40, 60, 100, 200].map((amt) {
                    return ActionChip(
                      label: Text('$amt ج.م'),
                      backgroundColor: AppTheme.darkCard,
                      labelStyle: const TextStyle(color: AppTheme.primaryLime, fontSize: 12),
                      onPressed: () => setState(() => _amountController.text = amt.toString()),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Charge Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _handleTopUp(walletProv),
                    child: Text('متابعة شحن $_selectedMethod'),
                  ),
                ),
                const SizedBox(height: 28),

                // 3. Transactions History
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('سجل العمليات والخصومات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('${walletProv.transactions.length} عملية', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),

                ...walletProv.transactions.map((tx) {
                  final isDeduction = tx.type == TransactionType.commissionDeduction;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDeduction
                                ? AppTheme.alertRed.withOpacity(0.15)
                                : AppTheme.primaryGreen.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDeduction ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isDeduction ? AppTheme.alertRed : AppTheme.primaryGreen,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.description,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${tx.paymentMethod} • ${tx.timestamp.hour}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isDeduction ? '-' : '+'}${tx.amount.toStringAsFixed(1)} ج.م',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDeduction ? AppTheme.alertRed : AppTheme.primaryGreen,
                          ),
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

  Widget _buildMethodTab(String name, String sub, IconData icon) {
    final isSelected = _selectedMethod == name;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = name),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryLime.withOpacity(0.15) : AppTheme.darkCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.primaryLime : AppTheme.darkBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppTheme.primaryLime : AppTheme.textMuted, size: 22),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isSelected ? AppTheme.primaryLime : Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTopUp(WalletProvider walletProv) {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (_selectedMethod == 'فوري' && amount < 40) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الحد الأدنى للشحن عبر فوري هو 40 ج.م')),
      );
      return;
    }

    if (_selectedMethod != 'فوري' && (amount < 60 || amount > 1600)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مبلغ الشحن يجب أن يكون بين 60 و1600 ج.م')),
      );
      return;
    }

    if (_selectedMethod == 'فوري') {
      final res = walletProv.initiateFawryTopUp(amount);
      _showFawryModal(res['refCode'], res['qrUrl'], amount);
    } else {
      walletProv.initiateMobileWalletTopUp(amount, _selectedMethod, '01012345678');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.primaryGreen,
          content: Text('تم شحن رصيد المحفظة بمبلغ $amount ج.م بنجاح عبر $_selectedMethod'),
        ),
      );
    }
  }

  void _showFawryModal(String refCode, String qrUrl, double amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 44, height: 5, decoration: BoxDecoration(color: AppTheme.darkBorder, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 18),
            const Text(
              'كود دفع فوري (Fawry Pay)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              'توجه لأي منفذ أو كشك فوري في إسنا وأعطه الرقم المرجعي التالي:',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryLime, width: 2),
              ),
              child: SelectableText(
                refCode,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: AppTheme.primaryLime,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'المبلغ المطلوب سداده: $amount ج.م',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.network(
                qrUrl,
                width: 160,
                height: 160,
                errorBuilder: (_, __, ___) => const Icon(Icons.qr_code, size: 80, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تم السداد بنجاح'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
