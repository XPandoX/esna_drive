import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '01012345678');
  final _nameController = TextEditingController(text: 'أحمد الطيب');
  final _otpController = TextEditingController(text: '1234');
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProv, child) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand Icon & Logo
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLime,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryLime.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.electric_rickshaw,
                        color: Colors.black,
                        size: 54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'إسنا درايف - EsnaDrive',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'أول منصة نقل ومزايدة ذكية في مركز ومدينة إسنا',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 32),

                    if (!_otpSent) ...[
                      // Phone & Name Input
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'الاسم الكريم',
                          prefixIcon: Icon(Icons.person, color: AppTheme.primaryLime),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف المصري',
                          hintText: '010XXXXXXXX / 011 / 012 / 015',
                          prefixIcon: Icon(Icons.phone_iphone, color: AppTheme.primaryLime),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _sendOtp(authProv),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text('إرسال كود التحقق (OTP)'),
                        ),
                      ),
                    ] else ...[
                      // OTP Verification
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.darkBorder),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'تم إرسال كود التحقق برسالة SMS إلى هاتفك',
                              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _phoneController.text.trim(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _otpController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                hintText: '1234',
                                helperText: 'كود التجربة السريع: 1234',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _verifyOtp(authProv),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text('تأكيد الدخول والمتابعة'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() => _otpSent = false),
                        child: const Text('تعديل رقم الهاتف', style: TextStyle(color: AppTheme.textMuted)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _sendOtp(AuthProvider authProv) async {
    final phone = _phoneController.text.trim();
    if (!authProv.isValidEgyptianPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم هاتف مصري صحيح (010/011/012/015)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final ok = await authProv.sendOtp(phone);
    setState(() {
      _isLoading = false;
      _otpSent = ok;
    });
  }

  void _verifyOtp(AuthProvider authProv) async {
    setState(() => _isLoading = true);
    final ok = await authProv.verifyOtp(
      _otpController.text.trim(),
      _nameController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (ok) {
      widget.onLoginSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كود التحقق غير صحيح، استخدم الكود التجريبي: 1234')),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
