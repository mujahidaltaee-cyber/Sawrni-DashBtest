import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';

class ProviderDetailsScreen extends StatelessWidget {
  const ProviderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Map<String, dynamic>.from((ModalRoute.of(context)?.settings.arguments as Map?) ?? {});
    final name = provider['display_name']?.toString() ?? 'مزود خدمة';
    final price = provider['starting_price_iqd']?.toString() ?? '-';
    return Scaffold(
      appBar: AppBar(title: const Text('ملف مزود الخدمة')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: SawrniBrand.midnight, borderRadius: BorderRadius.circular(30)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(provider['bio_ar']?.toString() ?? '', style: const TextStyle(color: Colors.white70, height: 1.8)),
                const SizedBox(height: 14),
                const Text('مزود معتمد من الإدارة', style: TextStyle(color: SawrniBrand.gold, fontWeight: FontWeight.w900)),
              ]),
            ),
            const SizedBox(height: 18),
            _InfoTile(label: 'نوع الخدمة', value: provider['service_type']?.toString() ?? '-'),
            _InfoTile(label: 'المدينة', value: provider['city']?.toString() ?? '-'),
            _InfoTile(label: 'التقييم', value: provider['rating']?.toString() ?? '-'),
            _InfoTile(label: 'السعر المبدئي', value: '$price IQD'),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/customer/booking', arguments: provider),
              child: const Text('طلب حجز'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: SawrniBrand.line)),
      child: Row(children: [
        Text(label, style: const TextStyle(color: SawrniBrand.muted, fontWeight: FontWeight.w700)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ]),
    );
  }
}
