import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';
import 'incoming_bookings_screen.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(SawrniBrand.softBg),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _Hero(),
              const SizedBox(height: 18),
              _MetricGrid(),
              const SizedBox(height: 18),
              _ProviderActionCard(
                title: 'طلبات الحجز الجديدة',
                subtitle: 'راجع الطلبات الواردة واقبل أو ارفض حسب توفر وقتك.',
                buttonText: 'فتح الطلبات',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const IncomingBookingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              const _ProviderActionCard(
                title: 'ملفات التسليم',
                subtitle: 'سيتم ربط ملفات التسليم الآمنة في المرحلة التالية.',
                buttonText: 'قريباً',
              ),
              const SizedBox(height: 12),
              const _ProviderActionCard(
                title: 'التقييمات',
                subtitle: 'التقييمات لا تظهر للعامة إلا بعد موافقة السوبر أدمن.',
                buttonText: 'قريباً',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(SawrniBrand.navy),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            SawrniBrand.appNameAr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            SawrniBrand.sloganAr,
            style: TextStyle(
              color: Color(SawrniBrand.gold),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'لوحة مزود الخدمة لإدارة الحجوزات، الردود، التسليمات، والتقييمات.',
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.7),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: const [
        _MetricCard(value: '0', label: 'طلبات جديدة'),
        _MetricCard(value: '0', label: 'حجوزات مؤكدة'),
        _MetricCard(value: '75K', label: 'حد الدين'),
        _MetricCard(value: '15%', label: 'عمولة المنصة'),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(SawrniBrand.text))),
          const Spacer(),
          Text(label, style: const TextStyle(fontSize: 14, color: Color(SawrniBrand.muted), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ProviderActionCard extends StatelessWidget {
  const _ProviderActionCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(SawrniBrand.text))),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 14, height: 1.7, color: Color(SawrniBrand.muted))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: enabled ? const Color(SawrniBrand.purple) : Colors.grey.shade200,
                foregroundColor: enabled ? Colors.white : Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
