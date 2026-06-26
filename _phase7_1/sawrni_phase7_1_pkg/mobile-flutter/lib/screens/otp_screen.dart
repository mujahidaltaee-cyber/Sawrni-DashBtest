import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/app_theme.dart';
import '../core/session_store.dart';
import '../widgets/sawrni_scaffold.dart';
import 'customer_home_screen.dart';
import 'provider_home_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  static const routeName = '/otp';

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController(text: '123456');
  final _api = ApiClient();
  final _store = SessionStore();
  bool _loading = false;
  String? _error;
  String _phone = '';
  String _role = 'customer';
  String? _devOtp;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _phone = args['phone']?.toString() ?? '';
      _role = args['role']?.toString() ?? 'customer';
      _devOtp = args['dev_otp']?.toString();
      if (_devOtp != null) _otpController.text = _devOtp!;
    }
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.post('/auth/verify-otp', {
        'phone': _phone,
        'role': _role,
        'otp': _otpController.text.trim(),
        'device_name': 'sawrni-flutter-dev',
      });

      await _store.save(token: result['token'].toString(), role: _role, phone: _phone);

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        _role == 'provider' ? ProviderHomeScreen.routeName : CustomerHomeScreen.routeName,
        (_) => false,
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'تعذر التحقق. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SawrniScaffold(
      title: 'رمز التحقق',
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          SawrniHero(
            badge: _role == 'provider' ? 'Provider OTP' : 'Customer OTP',
            title: 'أدخل رمز التحقق',
            subtitle: 'تم إرسال الرمز إلى $_phone. الجلسة تحفظ بأمان داخل التطبيق.',
          ),
          const SizedBox(height: 22),
          SawrniCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'رمز التحقق'),
                ),
                const SizedBox(height: 16),
                if (_error != null) Text(_error!, style: const TextStyle(color: SawrniTheme.danger, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _loading ? null : _verify, child: Text(_loading ? 'جاري التحقق...' : 'دخول')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
