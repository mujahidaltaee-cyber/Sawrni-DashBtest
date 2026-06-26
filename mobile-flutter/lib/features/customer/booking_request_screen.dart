import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';
import '../../core/network/sawrni_api_client.dart';
import '../../core/session/sawrni_session.dart';

class BookingRequestScreen extends StatefulWidget {
  const BookingRequestScreen({super.key});

  @override
  State<BookingRequestScreen> createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen> {
  final _api = SawrniApiClient();
  final _name = TextEditingController();
  final _city = TextEditingController(text: 'Baghdad');
  final _location = TextEditingController();
  final _notes = TextEditingController();
  final _amount = TextEditingController();
  bool _loading = false;
  String? _message;
  bool _success = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Map<String, dynamic>.from((ModalRoute.of(context)?.settings.arguments as Map?) ?? {});
    _amount.text = (provider['starting_price_iqd'] ?? 45000).toString();
  }

  Future<void> _submit() async {
    final provider = Map<String, dynamic>.from((ModalRoute.of(context)?.settings.arguments as Map?) ?? {});
    if (!SawrniSession.isLoggedIn) {
      setState(() {
        _success = false;
        _message = 'يجب تسجيل الدخول كعميل قبل إرسال الحجز.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final response = await _api.postJson('/mobile/customer/bookings', {
        'provider_id': provider['id'],
        'customer_name': _name.text.trim().isEmpty ? 'Customer' : _name.text.trim(),
        'city': _city.text.trim(),
        'location_text': _location.text.trim(),
        'customer_notes': _notes.text.trim(),
        'total_amount_iqd': int.tryParse(_amount.text.trim()) ?? provider['starting_price_iqd'] ?? 0,
      }, token: SawrniSession.token);
      setState(() {
        _success = true;
        _message = response['message_ar']?.toString() ?? 'تم إرسال طلب الحجز.';
      });
    } catch (e) {
      setState(() {
        _success = false;
        _message = 'تعذر إرسال الحجز. تأكد من تسجيل الدخول وتشغيل Laravel.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Map<String, dynamic>.from((ModalRoute.of(context)?.settings.arguments as Map?) ?? {});
    return Scaffold(
      appBar: AppBar(title: const Text('طلب حجز')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: SawrniBrand.line)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('تفاصيل الحجز', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(provider['display_name']?.toString() ?? 'مزود الخدمة', style: const TextStyle(color: SawrniBrand.purple, fontWeight: FontWeight.w900)),
                const SizedBox(height: 18),
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'اسم العميل')),
                const SizedBox(height: 12),
                TextField(controller: _city, decoration: const InputDecoration(labelText: 'المدينة')),
                const SizedBox(height: 12),
                TextField(controller: _location, decoration: const InputDecoration(labelText: 'الموقع أو العنوان')),
                const SizedBox(height: 12),
                TextField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر الكلي IQD')),
                const SizedBox(height: 12),
                TextField(controller: _notes, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'ملاحظات الحجز')),
                const SizedBox(height: 16),
                const Text('العمولة 15% من كامل العملية. بعد دفع العربون: التعديل خلال 3 ساعات، والإلغاء خلال ساعة واحدة فقط.', style: TextStyle(color: SawrniBrand.muted, height: 1.7)),
              ]),
            ),
            if (_message != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _success ? const Color(0xFFEAFBF1) : const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _success ? SawrniBrand.success : SawrniBrand.danger),
                ),
                child: Text(_message!, style: TextStyle(color: _success ? SawrniBrand.success : SawrniBrand.danger, fontWeight: FontWeight.w800)),
              ),
            ],
            const SizedBox(height: 18),
            ElevatedButton(onPressed: _loading ? null : _submit, child: Text(_loading ? 'جاري الإرسال...' : 'إرسال طلب الحجز')),
          ],
        ),
      ),
    );
  }
}
