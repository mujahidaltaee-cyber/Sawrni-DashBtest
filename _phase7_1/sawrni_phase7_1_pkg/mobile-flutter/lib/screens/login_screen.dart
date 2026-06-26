import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/app_theme.dart';
import '../widgets/sawrni_scaffold.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '07000000000');
  final _api = ApiClient();
  bool _loading = false;
  String? _error;
  String? _role;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['role'] is String) _role = args['role'] as String;
    _role ??= 'customer';
  }

  Future<void> _requestOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.post('/auth/request-otp', {
        'phone': _phoneController.text.trim(),
        'role': _role,
      });

      if (!mounted) return;
      Navigator.of(context).pushNamed(OtpScreen.routeName, arguments: {
        'phone': _phoneController.text.trim(),
        'role': _role,
        'dev_otp': result['dev_otp']?.toString(),
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'تعذر الاتصال بالخادم. تأكد من رابط API.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProvider = _role == 'provider';
    return SawrniScaffold(
      title: isProvider ? 'دخول مزود الخدمة' : 'دخول العميل',
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          SawrniHero(
            badge: 'Phone Login',
            title: isProvider ? 'أدخل رقم هاتف المزود' : 'أدخل رقم هاتف العميل',
            subtitle: isProvider ? 'بعد الدخول يمكنك إرسال ملف مزود الخدمة للمراجعة.' : 'بعد الدخول ستصل إلى واجهة العميل.',
          ),
          const SizedBox(height: 22),
          SawrniCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                ),
                const SizedBox(height: 16),
                if (_error != null) Text(_error!, style: const TextStyle(color: SawrniTheme.danger, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loading ? null : _requestOtp,
                  child: Text(_loading ? 'جاري الإرسال...' : 'إرسال رمز التحقق'),
                ),
                const SizedBox(height: 10),
                const Text('في بيئة التطوير رمز التحقق هو 123456. في الإنتاج يتم ربط SMS حقيقي ولا يظهر الرمز في الاستجابة.', style: TextStyle(color: SawrniTheme.muted, fontSize: 12, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
