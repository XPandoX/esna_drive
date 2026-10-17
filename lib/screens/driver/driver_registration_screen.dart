import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/driver_provider.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final _nameController = TextEditingController(text: 'محمود عبد الرازق');
  final _phoneController = TextEditingController(text: '01098765432');
  final _plateController = TextEditingController(text: 'إسنا - 418');
  String _vehicleType = 'توك توك';

  final Map<String, bool> _uploadedDocs = {
    'بطاقة الرقم القومي (الوجه الأمامي والخلفي)': true,
    'رخصة القيادة أو عقد مبايعة التوك توك': true,
    'صحيفة الحالة الجنائية (فيش وتشبيه حديث)': true,
    'صورة التوك توك / الموتوسيكل واضحة': true,
    'صورة شخصية حديثة (سيلفي الكابتن)': true,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (context, driverProv, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('توثيق حساب كابتن إسنا'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryLime.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified_user, color: AppTheme.primaryLime, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'التسجيل المعتمد بالوحدة المحلية لمركز ومدينة إسنا لضمان أمان الركاب والكباتن',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Form fields
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الثلاثي أو الرباعي',
                    prefixIcon: Icon(Icons.person, color: AppTheme.primaryLime),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف المحمول (مصر)',
                    prefixIcon: Icon(Icons.phone, color: AppTheme.primaryLime),
                  ),
                ),
                const SizedBox(height: 14),

                // Vehicle Type
                const Text(
                  'نوع المركبة:',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['توك توك', 'موتوسيكل', 'تروسيكل'].map((v) {
                    final isSelected = _vehicleType == v;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _vehicleType = v),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryLime.withOpacity(0.18) : AppTheme.darkCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryLime : AppTheme.darkBorder,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            v,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isSelected ? AppTheme.primaryLime : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _plateController,
                  decoration: const InputDecoration(
                    labelText: 'رقم التوك توك بالوحدة المحلية أو اللوحة المعدنية',
                    prefixIcon: Icon(Icons.confirmation_number, color: AppTheme.primaryLime),
                  ),
                ),
                const SizedBox(height: 24),

                // Documents Checklist
                const Text(
                  'المستندات المطلوبة للتوثيق:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 10),

                ..._uploadedDocs.keys.map((docName) {
                  final isDone = _uploadedDocs[docName]!;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDone ? AppTheme.primaryGreen.withOpacity(0.5) : AppTheme.darkBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isDone ? Icons.check_circle : Icons.upload_file,
                              color: isDone ? AppTheme.primaryGreen : AppTheme.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              docName,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _uploadedDocs[docName] = !_uploadedDocs[docName]!);
                          },
                          child: Text(
                            isDone ? 'مرفوع' : 'رفع ملف',
                            style: TextStyle(
                              color: isDone ? AppTheme.primaryGreen : AppTheme.primaryLime,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Save & Generate ID
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      driverProv.updateProfile(
                        name: _nameController.text.trim(),
                        phone: _phoneController.text.trim(),
                        vehicleType: _vehicleType,
                        vehicleNumber: _plateController.text.trim(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppTheme.primaryGreen,
                          content: Text('تم توثيق الحساب وتوليد بطاقة QR الرقمية بنجاح!'),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('حفظ وتوليد بطاقة هوية الكابتن الرقمية (QR)'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _plateController.dispose();
    super.dispose();
  }
}
