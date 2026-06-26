import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/role_select_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/customer_home_screen.dart';
import 'screens/provider_home_screen.dart';
import 'screens/provider_profile_screen.dart';

void main() {
  runApp(const SawrniApp());
}

class SawrniApp extends StatelessWidget {
  const SawrniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sawrni',
      theme: SawrniTheme.light(),
      locale: const Locale('ar'),
      initialRoute: '/',
      routes: {
        '/': (_) => const RoleSelectScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        OtpScreen.routeName: (_) => const OtpScreen(),
        CustomerHomeScreen.routeName: (_) => const CustomerHomeScreen(),
        ProviderHomeScreen.routeName: (_) => const ProviderHomeScreen(),
        ProviderProfileScreen.routeName: (_) => const ProviderProfileScreen(),
      },
    );
  }
}
