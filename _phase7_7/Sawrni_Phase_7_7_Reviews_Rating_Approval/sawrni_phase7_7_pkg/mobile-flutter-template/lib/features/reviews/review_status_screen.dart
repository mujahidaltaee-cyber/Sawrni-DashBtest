import 'package:flutter/material.dart';

class ReviewStatusScreen extends StatelessWidget {
  const ReviewStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statuses = [
      ('pending_review', 'بانتظار مراجعة الإدارة', 'لا يظهر للعامة الآن.'),
      ('approved', 'تم النشر', 'أصبح التقييم ظاهراً في ملف مزود الخدمة.'),
      ('rejected', 'مرفوض', 'لن يظهر التقييم للعامة.'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F5FB),
        appBar: AppBar(
          title: const Text('حالة التقييمات'),
          backgroundColor: const Color(0xFF081426),
          foregroundColor: Colors.white,
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: statuses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final item = statuses[index];
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE4E0EC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$2, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF081426))),
                  const SizedBox(height: 6),
                  Text(item.$3, style: const TextStyle(fontSize: 14, color: Color(0xFF657084))),
                  const SizedBox(height: 10),
                  Text(item.$1, style: const TextStyle(fontSize: 12, color: Color(0xFF6030A8), fontWeight: FontWeight.w800)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
