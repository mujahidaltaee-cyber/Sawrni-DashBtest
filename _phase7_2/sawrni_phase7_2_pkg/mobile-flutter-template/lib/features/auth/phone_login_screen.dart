import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';
import '../../core/network/sawrni_api_client.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key, required this.role});
  final String role;

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phone = TextEditingController(text: '07000000000');
  final _api = SawrniApiClient();
  bool _loading = false;
  String? _error;

  Future<void> _continue() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _api.postJson('/app-auth/request-otp', {'phone': _phone.text.trim(), 'role': widget.role});
    } catch (_) {
      // In early local development, continue to OTP screen even if backend endpoint is still being connected.
    }
    if (!mounted) return;
    setState(() { _loading = false; });
    Navigator.of(context).pushNamed('/otp', arguments: {'phone': _phone.text.trim(), 'role': widget.role});
  }

  @override
  Widget build(BuildContext context) {
    final isProvider = widget.role == 'provider';
    return Scaffold(
      appBar: AppBar(title: Text(isProvider ? 'دخول مزود الخدمة' : 'دخول العميل')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Text('صورني', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: SawrniBrand.ink)),
            const SizedBox(height: 8),
            const Text(SawrniBrand.sloganAr, style: TextStyle(color: SawrniBrand.gold, fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 28),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'رقم الهاتف', hintText: '07xxxxxxxxx'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: SawrniBrand.danger)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _continue,
              child: Text(_loading ? 'جاري الإرسال...' : 'إرسال رمز التحقق'),
            ),
            const SizedBox(height: 14),
            const Text('رمز التطوير الحالي: 123456', textAlign: TextAlign.center, style: TextStyle(color: SawrniBrand.muted)),
          ],
        ),
      ),
    );
  }
}
