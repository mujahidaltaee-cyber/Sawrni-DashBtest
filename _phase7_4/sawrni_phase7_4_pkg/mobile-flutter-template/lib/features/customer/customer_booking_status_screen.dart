import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';

class CustomerBookingStatusScreen extends StatelessWidget {
  const CustomerBookingStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(SawrniBrand.softBg),
        appBar: AppBar(
          title: const Text('حجوزاتي'),
          backgroundColor: const Color(SawrniBrand.softBg),
          foregroundColor: const Color(SawrniBrand.text),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تتبع حالة الحجز', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  SizedBox(height: 10),
                  Text(
                    'عند قبول مزود الخدمة سيظهر للعميل أن الحجز بانتظار دفع العربون. بيانات التواصل الحساسة تبقى محجوبة قبل تأكيد الحجز.',
                    style: TextStyle(color: Color(SawrniBrand.muted), height: 1.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
