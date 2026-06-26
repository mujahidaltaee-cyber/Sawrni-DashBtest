import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 900), () {
      if (mounted) Navigator.of(context).pushReplacementNamed('/role');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SawrniBrand.midnight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                ),
                child: Column(
                  children: const [
                    Text('صورني', style: TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.w900)),
                    SizedBox(height: 12),
                    Text(SawrniBrand.sloganAr, textAlign: TextAlign.center, style: TextStyle(color: SawrniBrand.gold, fontSize: 18, fontWeight: FontWeight.w800)),
                    SizedBox(height: 10),
                    Text('Sawrni', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              const Text('ابدأ التصوير، التعديل، والتسليم من مكان واحد.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
