import 'package:flutter/material.dart';
import 'delivery_models.dart';

class CustomerDeliveryAccessScreen extends StatelessWidget {
  final int bookingId;
  const CustomerDeliveryAccessScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final demoRows = <SawrniDeliveryItem>[
      SawrniDeliveryItem(
        id: 1,
        bookingId: bookingId,
        title: 'ملفات جلسة التصوير',
        status: 'approved',
        fileName: 'sawrni-delivery.zip',
        notes: 'جاهزة للتحميل عبر رابط مؤقت وآمن.',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('ملفات التسليم')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'استوديو كامل بجيبك',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF5B2EA6)),
            ),
            const SizedBox(height: 16),
            Text('تسليمات الحجز #$bookingId', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
            const Text('تظهر هنا فقط الملفات التي وافقت عليها الإدارة. روابط التحميل مؤقتة ويتم تسجيل كل عملية وصول.'),
            const SizedBox(height: 20),
            for (final item in demoRows)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(item.fileName ?? 'ملف التسليم'),
                      const SizedBox(height: 8),
                      Text(item.notes ?? ''),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('إنشاء رابط تحميل آمن'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
