import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/sawrni_scaffold.dart';
import 'login_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  void _openLogin(BuildContext context, String role) {
    Navigator.of(context).pushNamed(LoginScreen.routeName, arguments: {'role': role});
  }

  @override
  Widget build(BuildContext context) {
    return SawrniScaffold(
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const SawrniHero(
            badge: 'Sawrni Phase 7.1',
            title: 'تطبيق صورني',
            subtitle: 'بداية تطبيق iOS و Android الحقيقي للعملاء ومزودي الخدمة. الدخول برقم الهاتف، والبيانات الحساسة تبقى مخفية حسب قواعد المنصة.',
          ),
          const SizedBox(height: 24),
          SawrniCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أنا عميل', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: SawrniTheme.text)),
                const SizedBox(height: 10),
                const Text('تصفح خدمات التصوير والتعديل والمودلز واحجز الخدمة لاحقاً عبر قواعد الدفع والعمولة.', style: TextStyle(color: SawrniTheme.muted, height: 1.8)),
                const SizedBox(height: 18),
                ElevatedButton(onPressed: () => _openLogin(context, 'customer'), child: const Text('الدخول كعميل')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SawrniCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أنا مزود خدمة', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: SawrniTheme.text)),
                const SizedBox(height: 10),
                const Text('سجل كمصور أو محرر أو مودل. حسابك لا يظهر للعملاء قبل موافقة الإدارة/COO.', style: TextStyle(color: SawrniTheme.muted, height: 1.8)),
                const SizedBox(height: 18),
                OutlinedButton(onPressed: () => _openLogin(context, 'provider'), child: const Text('الدخول كمزود خدمة')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
