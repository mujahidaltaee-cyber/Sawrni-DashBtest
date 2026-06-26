import 'package:flutter/material.dart';
import 'sawrni_notification.dart';

class NotificationCenterPage extends StatelessWidget {
  final String audience;

  const NotificationCenterPage({super.key, required this.audience});

  List<SawrniNotification> get _items => [
        SawrniNotification(
          id: '1',
          titleAr: 'تم قبول طلب الحجز',
          bodyAr: 'مزود الخدمة قبل طلبك. يرجى إكمال العربون لتأكيد الحجز.',
          type: 'booking_accepted',
          audience: 'customer',
          isRead: false,
          createdAt: DateTime.now(),
        ),
        SawrniNotification(
          id: '2',
          titleAr: 'ملفات التسليم بانتظار المراجعة',
          bodyAr: 'تم رفع ملفات التسليم وسيتم إتاحتها بعد موافقة الإدارة.',
          type: 'delivery_pending_review',
          audience: 'customer',
          isRead: false,
          createdAt: DateTime.now(),
        ),
        SawrniNotification(
          id: '3',
          titleAr: 'طلب حجز جديد',
          bodyAr: 'لديك طلب حجز جديد. الرجاء مراجعة التفاصيل والقبول أو الرفض.',
          type: 'provider_new_booking',
          audience: 'provider',
          isRead: false,
          createdAt: DateTime.now(),
        ),
        SawrniNotification(
          id: '4',
          titleAr: 'تنبيه دين',
          bodyAr: 'رصيد الدين يقترب من حد 75,000 د.ع. يرجى التسديد لتجنب التعليق.',
          type: 'debt_warning',
          audience: 'provider',
          isRead: true,
          createdAt: DateTime.now(),
        ),
      ].where((n) => n.audience == audience).toList();

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF071326);
    const purple = Color(0xFF522E91);
    const gold = Color(0xFFD9A441);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          title: const Text('الإشعارات'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('صورني', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  SizedBox(height: 6),
                  Text('استوديو كامل بجيبك', style: TextStyle(color: gold, fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ..._items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: item.isRead ? const Color(0xFFE2E8F0) : gold.withOpacity(.6)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 18, offset: const Offset(0, 10))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: item.isRead ? const Color(0xFFF1F5F9) : purple.withOpacity(.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_iconFor(item.type), color: item.isRead ? Colors.grey : purple),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.titleAr, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: navy)),
                            const SizedBox(height: 6),
                            Text(item.bodyAr, style: const TextStyle(color: Color(0xFF64748B), height: 1.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    if (type.contains('booking')) return Icons.event_available_rounded;
    if (type.contains('delivery')) return Icons.folder_special_rounded;
    if (type.contains('review')) return Icons.star_rounded;
    if (type.contains('debt')) return Icons.warning_amber_rounded;
    return Icons.notifications_rounded;
  }
}
