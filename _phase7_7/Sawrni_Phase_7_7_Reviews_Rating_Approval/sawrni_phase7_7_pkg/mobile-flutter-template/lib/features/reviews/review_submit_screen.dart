import 'package:flutter/material.dart';

class ReviewSubmitScreen extends StatefulWidget {
  const ReviewSubmitScreen({super.key});

  @override
  State<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
}

class _ReviewSubmitScreenState extends State<ReviewSubmitScreen> {
  int rating = 5;
  final commentController = TextEditingController();
  bool submitted = false;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F5FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFF081426),
          foregroundColor: Colors.white,
          title: const Text('تقييم الخدمة'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF081426),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('استوديو كامل بجيبك', style: TextStyle(color: Color(0xFFF4C45F), fontSize: 16, fontWeight: FontWeight.w800)),
                  SizedBox(height: 10),
                  Text('شارك تجربتك بعد استلام الخدمة', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                  SizedBox(height: 8),
                  Text('لن يظهر تقييمك للعامة إلا بعد مراجعة الإدارة.', style: TextStyle(color: Colors.white70, fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('التقييم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final value = index + 1;
                        return IconButton(
                          onPressed: () => setState(() => rating = value),
                          icon: Icon(
                            value <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: const Color(0xFFF4C45F),
                            size: 36,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: commentController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: 'ملاحظتك',
                        hintText: 'اكتب رأيك بالخدمة بشكل واضح...',
                        filled: true,
                        fillColor: const Color(0xFFF8F8FB),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6030A8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () => setState(() => submitted = true),
                        child: const Text('إرسال للمراجعة', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    if (submitted) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF8EF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text('تم إرسال التقييم وينتظر موافقة الإدارة قبل النشر.', style: TextStyle(color: Color(0xFF157A3A), fontWeight: FontWeight.w700)),
                      ),
                    ],
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
