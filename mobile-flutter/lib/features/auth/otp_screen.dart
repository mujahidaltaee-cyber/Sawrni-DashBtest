import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';
import '../../core/network/sawrni_api_client.dart';
import '../../core/session/sawrni_session.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otp = TextEditingController(text: '123456');
  final _api = SawrniApiClient();
  bool _loading = false;
  String? _error;

  Future<void> _verify() async {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final role = (args['role'] ?? 'customer').toString();
    final phone = (args['phone'] ?? '').toString();
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _api.postJson('/app-auth/verify-otp', {
        'phone': phone,
        'role': role,
        'otp': _otp.text.trim(),
      });
      final token = (response['token'] ?? '').toString();
      if (token.isNotEmpty) {
        SawrniSession.save(
          newToken: token,
          newRole: role,
          newPhone: phone,
          displayName: response['user'] is Map ? (response['user']['name']?.toString()) : null,
        );
      }
    } catch (e) {
      _error = 'تعذر التحقق من الخادم. تأكد من تشغيل Laravel وربط رابط API.';
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (_error != null && !SawrniSession.isLoggedIn) return;

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
              const Text(SawrniBrand.sloganAr, style: TextStyle(color: SawrniBrand.gold, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              TextField(controller: _otp, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'OTP')),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: SawrniBrand.danger, fontWeight: FontWeight.w700)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loading ? null : _verify, child: Text(_loading ? 'جاري التحقق...' : 'تأكيد الدخول')),
            ],
          ),
        ),
      ),
    );
  }
}
