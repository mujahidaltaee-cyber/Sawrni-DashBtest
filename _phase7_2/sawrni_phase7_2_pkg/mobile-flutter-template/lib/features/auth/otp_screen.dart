import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';
import '../../core/network/sawrni_api_client.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otp = TextEditingController(text: '123456');
  final _api = SawrniApiClient();
  bool _loading = false;

  Future<void> _verify() async {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final role = (args['role'] ?? 'customer').toString();
    setState(() => _loading = true);
    try {
      await _api.postJson('/app-auth/verify-otp', {
        'phone': args['phone'] ?? '',
        'role': role,
        'otp': _otp.text.trim(),
      });
    } catch (_) {}
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushNamedAndRemoveUntil(
      role == 'provider' ? '/provider/home' : '/customer/home',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رمز التحقق')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('أدخل رمز التحقق', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              const Text('لأغراض التطوير استخدم 123456.', style: TextStyle(color: SawrniBrand.muted)),
              const SizedBox(height: 24),
              TextField(controller: _otp, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'OTP')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loading ? null : _verify, child: Text(_loading ? 'جاري التحقق...' : 'تأكيد الدخول')),
            ],
          ),
        ),
      ),
    );
  }
}
