import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'passenger/passenger_home_screen.dart';
import 'driver/driver_home_screen.dart';
import 'admin/esna_admin_dashboard_screen.dart';
import 'auth/login_screen.dart';

class MainWrapperScreen extends StatelessWidget {
  const MainWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProv, child) {
        if (!authProv.isLoggedIn) {
          return LoginScreen(
            onLoginSuccess: () {},
          );
        }

        switch (authProv.currentRole) {
          case AppRole.passenger:
            return const PassengerHomeScreen();
          case AppRole.driver:
            return const DriverHomeScreen();
          case AppRole.admin:
            return const EsnaAdminDashboardScreen();
        }
      },
    );
  }
}
