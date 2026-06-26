import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';

class ProviderHomeScreen extends StatelessWidget {
  const ProviderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مزود الخدمة')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: SawrniBrand.cream, borderRadius: BorderRadius.circular(28), border: Border.all(color: SawrniBrand.gold)),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('حسابك لا يظهر للعملاء قبل الموافقة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: SawrniBrand.ink)),
                SizedBox(height: 8),
                Text('أكمل ملف الخدمة ليتم مراجعته من الإدارة/COO داخل لوحة التحكم.', style: TextStyle(color: SawrniBrand.muted, height: 1.7)),
              ]),
            ),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: () => Navigator.of(context).pushNamed('/provider/profile'), child: const Text('إكمال ملف مزود الخدمة')),
          ],
        ),
      ),
    );
  }
}
