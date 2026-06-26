import 'package:flutter/material.dart';
import 'core/brand/sawrni_brand.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/role_choice_screen.dart';
import 'features/auth/phone_login_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/home/customer_home_screen.dart';
import 'features/home/provider_home_screen.dart';
import 'features/provider/provider_profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SawrniMobileApp());
}

class SawrniMobileApp extends StatelessWidget {
  const SawrniMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: SawrniBrand.appNameAr,
      theme: SawrniBrand.theme(),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/role': (_) => const RoleChoiceScreen(),
        '/login/customer': (_) => const PhoneLoginScreen(role: 'customer'),
        '/login/provider': (_) => const PhoneLoginScreen(role: 'provider'),
        '/otp': (_) => const OtpScreen(),
        '/customer/home': (_) => const CustomerHomeScreen(),
        '/provider/home': (_) => const ProviderHomeScreen(),
        '/provider/profile': (_) => const ProviderProfileScreen(),
      },
    );
  }
}
