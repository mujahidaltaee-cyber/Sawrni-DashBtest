import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صورني')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: const [
            Text('استوديو كامل بجيبك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: SawrniBrand.ink)),
            SizedBox(height: 8),
            Text('اختر الخدمة التي تحتاجها وابدأ الحجز.', style: TextStyle(color: SawrniBrand.muted)),
            SizedBox(height: 18),
            _ServiceCard(title: 'تصوير', body: 'جلسات تخرج، أعراس، منتجات، مناسبات.'),
            _ServiceCard(title: 'تعديل صور', body: 'تحسين، رتوش، ألوان، تسليم رقمي.'),
            _ServiceCard(title: 'مودلز', body: 'حجز مودلز للتصوير التجاري والإعلانات.'),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: SawrniBrand.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(body, style: const TextStyle(color: SawrniBrand.muted, height: 1.7)),
      ]),
    );
  }
}
