import 'package:flutter/material.dart';

class ProviderDeliveryUploadScreen extends StatefulWidget {
  final int bookingId;
  const ProviderDeliveryUploadScreen({super.key, required this.bookingId});

  @override
  State<ProviderDeliveryUploadScreen> createState() => _ProviderDeliveryUploadScreenState();
}

class _ProviderDeliveryUploadScreenState extends State<ProviderDeliveryUploadScreen> {
  final _titleController = TextEditingController(text: 'ملفات التسليم');
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  String? _message;

  Future<void> _submitPlaceholder() async {
    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isSubmitting = false;
      _message = 'تم تجهيز طلب رفع التسليم. عند ربط API سيتم رفع الملفات ومراجعتها من الإدارة قبل وصولها للعميل.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تسليم الملفات')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'استوديو كامل بجيبك',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF5B2EA6)),
            ),
            const SizedBox(height: 12),
            Text('رقم الحجز: ${widget.bookingId}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'عنوان التسليم'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'ملاحظات للعميل أو الإدارة'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'مكان اختيار الملفات سيُربط مع file picker في مرحلة البناء على Android Studio. لا يتم إرسال روابط مباشرة للعميل قبل موافقة الإدارة.',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPlaceholder,
              child: Text(_isSubmitting ? 'جاري الإرسال...' : 'إرسال التسليم للمراجعة'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFFAF3),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(_message!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
