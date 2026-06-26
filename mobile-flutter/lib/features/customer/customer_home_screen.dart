import 'package:flutter/material.dart';
import 'booking_lifecycle_screen.dart';
import '../shared/sawrni_ui.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SawrniScaffold(
      title: 'تطبيق صورني',
      subtitle: 'استوديو كامل بجيبك. تصفح المزودين واحجز جلسة تصوير أو تعديل أو مودل بخطوات واضحة.',
      child: Column(
        children: [
          SawrniInfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المرحلة الحالية',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                ),
                const SizedBox(height: 8),
                const Text('Phase 7.5: دورة الحجز والعربون أصبحت جزءاً من تطبيق العميل.'),
                const SizedBox(height: 16),
                SawrniPrimaryButton(
                  label: 'فتح دورة الحجز',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BookingLifecycleScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
