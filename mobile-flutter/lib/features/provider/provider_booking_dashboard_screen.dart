import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';
import '../shared/sawrni_ui.dart';

class ProviderBookingDashboardScreen extends StatelessWidget {
  const ProviderBookingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SawrniScaffold(
      title: 'لوحة المزود',
      subtitle: 'استلم طلبات الحجز، اقبل أو ارفض، ولا تظهر بيانات التواصل إلا بعد تأكيد الحجز.',
      child: Column(
        children: [
          SawrniInfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('طلب حجز جديد', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                const SizedBox(height: 10),
                const Text('جلسة تصوير تخرج · بغداد · السعر 120,000 IQD'),
                const SizedBox(height: 10),
                const Text('هاتف العميل: مخفي حتى تأكيد الحجز', style: TextStyle(color: SawrniBrand.muted)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: SawrniPrimaryButton(label: 'قبول', color: SawrniBrand.success, onPressed: () {})),
                    const SizedBox(width: 10),
                    Expanded(child: SawrniPrimaryButton(label: 'رفض', color: SawrniBrand.danger, onPressed: () {})),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
