import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/app_theme.dart';
import '../core/session_store.dart';
import '../widgets/sawrni_scaffold.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});
  static const routeName = '/provider/profile';

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final _api = ApiClient();
  final _store = SessionStore();
  final _name = TextEditingController(text: 'Hussein Photo');
  final _city = TextEditingController(text: 'Baghdad');
  final _bio = TextEditingController(text: 'Graduation and outdoor photographer.');
  final _portfolio = TextEditingController(text: 'Portfolio files will be added in the next upload phase.');

  String _providerType = 'photographer';
  String _category = 'photography';
  String _plan = 'basic';
  bool _loading = false;
  String? _message;
  bool _success = false;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _message = null;
      _success = false;
    });

    try {
      final token = await _store.token();
      final result = await _api.post('/provider/profile', {
        'display_name': _name.text.trim(),
        'provider_type': _providerType,
        'category': _category,
        'city': _city.text.trim(),
        'subscription_plan': _plan,
        'bio': _bio.text.trim(),
        'public_portfolio_note': _portfolio.text.trim(),
      }, token: token);

      setState(() {
        _success = true;
        _message = result['message_ar']?.toString() ?? 'تم إرسال الملف للمراجعة.';
      });
    } on ApiException catch (e) {
      setState(() => _message = e.message);
    } catch (e) {
      setState(() => _message = 'تعذر إرسال الملف.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SawrniScaffold(
      title: 'ملف مزود الخدمة',
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const SawrniHero(
            badge: 'Provider Registration',
            title: 'إرسال الملف للمراجعة',
            subtitle: 'أي تحديث يعيد الملف إلى حالة الانتظار. لا يتم نشر المزود قبل موافقة الإدارة/COO.',
          ),
          const SizedBox(height: 20),
          SawrniCard(
            child: Column(
              children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'اسم العرض')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _providerType,
                  decoration: const InputDecoration(labelText: 'نوع المزود'),
                  items: const [
                    DropdownMenuItem(value: 'photographer', child: Text('مصور')),
                    DropdownMenuItem(value: 'editor', child: Text('محرر صور')),
                    DropdownMenuItem(value: 'model', child: Text('مودل')),
                  ],
                  onChanged: (v) => setState(() => _providerType = v ?? 'photographer'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'القسم'),
                  items: const [
                    DropdownMenuItem(value: 'photography', child: Text('تصوير')),
                    DropdownMenuItem(value: 'photo_editing', child: Text('تعديل صور')),
                    DropdownMenuItem(value: 'modeling', child: Text('مودلز')),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? 'photography'),
                ),
                const SizedBox(height: 12),
                TextField(controller: _city, decoration: const InputDecoration(labelText: 'المدينة')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _plan,
                  decoration: const InputDecoration(labelText: 'خطة الاشتراك'),
                  items: const [
                    DropdownMenuItem(value: 'basic', child: Text('Basic')),
                    DropdownMenuItem(value: 'standard', child: Text('Standard')),
                    DropdownMenuItem(value: 'premium', child: Text('Premium')),
                  ],
                  onChanged: (v) => setState(() => _plan = v ?? 'basic'),
                ),
                const SizedBox(height: 12),
                TextField(controller: _bio, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'نبذة عامة')),
                const SizedBox(height: 12),
                TextField(controller: _portfolio, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'ملاحظة بورتفوليو عامة')),
                const SizedBox(height: 18),
                if (_message != null)
                  Text(_message!, style: TextStyle(color: _success ? SawrniTheme.success : SawrniTheme.danger, fontWeight: FontWeight.w800, height: 1.6)),
                const SizedBox(height: 10),
                ElevatedButton(onPressed: _loading ? null : _submit, child: Text(_loading ? 'جاري الإرسال...' : 'إرسال للمراجعة')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
