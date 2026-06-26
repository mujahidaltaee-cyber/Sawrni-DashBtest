import 'package:flutter/material.dart';

class ProviderPublicReviewsScreen extends StatelessWidget {
  const ProviderPublicReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F5FB),
        appBar: AppBar(
          title: const Text('تقييمات مزود الخدمة'),
          backgroundColor: const Color(0xFF081426),
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('التقييمات المنشورة فقط', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF081426))),
                  SizedBox(height: 8),
                  Text('يعرض التطبيق التقييمات التي تمت الموافقة عليها من الإدارة فقط، لحماية جودة المنصة وسمعة المزودين والعملاء.', style: TextStyle(color: Color(0xFF657084), height: 1.6)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ReviewCard(rating: 5, text: 'الخدمة ممتازة والتعامل احترافي جداً.'),
            _ReviewCard(rating: 4, text: 'التصوير جميل والتسليم كان واضحاً.'),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final int rating;
  final String text;

  const _ReviewCard({required this.rating, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE4E0EC))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: List.generate(5, (i) => Icon(i < rating ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFF4C45F)))),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontSize: 15, color: Color(0xFF081426))),
        ],
      ),
    );
  }
}
