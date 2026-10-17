import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppRole { passenger, driver, admin }

class AuthProvider extends ChangeNotifier {
  AppRole _currentRole = AppRole.passenger;
  String? _phoneNumber;
  String _userName = 'أحمد الطيب';
  String _userId = 'user_esna_101';
  bool _isLoggedIn = true;
  String? _pendingVerificationPhone;

  AppRole get currentRole => _currentRole;
  String? get phoneNumber => _phoneNumber;
  String get userName => _userName;
  String get userId => _userId;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('user_name') ?? 'أحمد الطيب';
      _phoneNumber = prefs.getString('user_phone') ?? '01012345678';
      final roleStr = prefs.getString('user_role');
      if (roleStr != null) {
        _currentRole = AppRole.values.firstWhere(
          (r) => r.name == roleStr,
          orElse: () => AppRole.passenger,
        );
      }
      notifyListeners();
    } catch (_) {}
  }

  void switchRole(AppRole newRole) async {
    _currentRole = newRole;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', newRole.name);
    } catch (_) {}
  }

  bool isValidEgyptianPhone(String phone) {
    final clean = phone.replaceAll(' ', '').replaceAll('-', '');
    final regex = RegExp(r'^(010|011|012|015)[0-9]{8}$');
    return regex.hasMatch(clean);
  }

  Future<bool> sendOtp(String phone) async {
    if (!isValidEgyptianPhone(phone)) return false;
    _pendingVerificationPhone = phone;
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> verifyOtp(String code, String name) async {
    if (code == '1234' || code == '0000') {
      _phoneNumber = _pendingVerificationPhone ?? '01012345678';
      _userName = name.isNotEmpty ? name : 'عميل إسنا';
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _isLoggedIn = true;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', _userName);
        await prefs.setString('user_phone', _phoneNumber!);
        await prefs.setBool('is_logged_in', true);
      } catch (_) {}

      notifyListeners();
      return true;
    }
    return false;
  }

  void updateName(String name) async {
    _userName = name;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
    } catch (_) {}
  }

  void logout() async {
    _isLoggedIn = false;
    _currentRole = AppRole.passenger;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
  }
}
