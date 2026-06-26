import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';
import '../../core/session/sawrni_session.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صورني'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/customer/bookings'),
            child: const Text('حجوزاتي'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SawrniBrand.navy,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('تطبيق صورني', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 8),
                const Text(SawrniBrand.sloganAr, style: TextStyle(color: SawrniBrand.gold, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 10),
                Text(
                  SawrniSession.isLoggedIn ? 'أهلاً ${SawrniSession.phone ?? ''}' : 'سجل دخولك ثم احجز الخدمة المناسبة.',
                  style: const TextStyle(color: Colors.white70, height: 1.8),
                ),
              ]),
            ),
            const SizedBox(height: 18),
            _ServiceCard(
              title: 'تصوير',
              body: 'جلسات تخرج، أعراس، منتجات، مناسبات.',
              onTap: () => Navigator.of(context).pushNamed('/customer/providers', arguments: {'service_type': 'photography', 'title': 'مزودو التصوير'}),
            ),
            _ServiceCard(
              title: 'تعديل صور',
              body: 'تحسين، رتوش، ألوان، تسليم رقمي.',
              onTap: () => Navigator.of(context).pushNamed('/customer/providers', arguments: {'service_type': 'editing', 'title': 'مزودو تعديل الصور'}),
            ),
            _ServiceCard(
              title: 'مودلز',
              body: 'حجز مودلز للتصوير التجاري والإعلانات.',
              onTap: () => Navigator.of(context).pushNamed('/customer/providers', arguments: {'service_type': 'modeling', 'title': 'المودلز'}),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.title, required this.body, required this.onTap});
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: SawrniBrand.line)),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(body, style: const TextStyle(color: SawrniBrand.muted, height: 1.7)),
            ]),
          ),
          const Icon(Icons.arrow_back_ios_new_rounded, color: SawrniBrand.purple),
        ]),
      ),
    );
  }
}
