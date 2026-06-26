import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';

class RoleChoiceScreen extends StatelessWidget {
  const RoleChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: SawrniBrand.midnight,
                borderRadius: BorderRadius.circular(34),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sawrni Phase 7.2', style: TextStyle(color: SawrniBrand.gold, fontWeight: FontWeight.w900)),
                  SizedBox(height: 12),
                  Text('تطبيق صورني', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
                  SizedBox(height: 12),
                  Text(SawrniBrand.sloganAr, style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _RoleCard(
              title: 'أنا عميل',
              body: 'احجز مصور، محرر، أو مودل، وتابع الطلب من جيبك.',
              button: 'الدخول كعميل',
              filled: true,
              onTap: () => Navigator.of(context).pushNamed('/login/customer'),
            ),
            const SizedBox(height: 16),
            _RoleCard(
              title: 'أنا مزود خدمة',
              body: 'سجل خدماتك وملفاتك، ولن يظهر حسابك للعملاء إلا بعد موافقة الإدارة.',
              button: 'الدخول كمزود خدمة',
              filled: false,
              onTap: () => Navigator.of(context).pushNamed('/login/provider'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.title, required this.body, required this.button, required this.onTap, required this.filled});
  final String title;
  final String body;
  final String button;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: SawrniBrand.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: SawrniBrand.ink)),
          const SizedBox(height: 10),
          Text(body, style: const TextStyle(fontSize: 15, height: 1.8, color: SawrniBrand.muted)),
          const SizedBox(height: 18),
          filled ? ElevatedButton(onPressed: onTap, child: Text(button)) : OutlinedButton(onPressed: onTap, child: Text(button)),
        ],
      ),
    );
  }
}
