import 'package:flutter/material.dart';
import 'core/brand/sawrni_brand.dart';
import 'features/customer/customer_home_screen.dart';

void main() {
  runApp(const SawrniMobileApp());
}

class SawrniMobileApp extends StatelessWidget {
  const SawrniMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: SawrniBrand.appNameAr,
      debugShowCheckedModeBanner: false,
      theme: SawrniBrand.theme(),
      home: const CustomerHomeScreen(),
    );
  }
}
