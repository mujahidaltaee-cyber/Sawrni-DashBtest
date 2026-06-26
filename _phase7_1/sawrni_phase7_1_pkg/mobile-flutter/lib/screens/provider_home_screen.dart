import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/app_theme.dart';
import '../core/session_store.dart';
import '../widgets/sawrni_scaffold.dart';
import 'provider_profile_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});
  static const routeName = '/provider';

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  final _api = ApiClient();
  final _store = SessionStore();
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await _store.token();
      final result = await _api.get('/provider/home', token: token);
      if (mounted) setState(() => _data = result);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'تعذر تحميل بيانات المزود.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).pushNamed(ProviderProfileScreen.routeName);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final provider = (_data?['provider'] as Map?) ?? {};
    final approval = provider['approval_status']?.toString() ?? 'pending';
    final visible = provider['is_visible_to_customers'] == true;

    return SawrniScaffold(
      title: 'واجهة المزود',
      actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const SawrniHero(
              badge: 'Provider App',
              title: 'إدارة ملف مزود الخدمة',
              subtitle: 'أرسل ملفك للمراجعة. الحساب لا يظهر للعملاء قبل موافقة الإدارة/COO، ويتم تتبع الديون والتعليق من الخادم.',
            ),
            const SizedBox(height: 20),
            if (_loading) const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())),
            if (_error != null) Text(_error!, style: const TextStyle(color: SawrniTheme.danger, fontWeight: FontWeight.w800)),
            if (!_loading && _error == null) ...[
              SawrniCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: visible ? const Color(0xFFE7F8EE) : const Color(0xFFFFF7E6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(approval, style: TextStyle(color: visible ? SawrniTheme.success : const Color(0xFF92400E), fontWeight: FontWeight.w900)),
                        ),
                        const Spacer(),
                        Text(visible ? 'ظاهر للعملاء' : 'غير ظاهر للعملاء', style: const TextStyle(fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('${provider['display_name'] ?? 'لم يتم إكمال الملف بعد'}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(_data?['message_ar']?.toString() ?? '', style: const TextStyle(color: SawrniTheme.muted, height: 1.7)),
                    const SizedBox(height: 18),
                    ElevatedButton(onPressed: _openProfile, child: const Text('إكمال / تحديث ملف المزود')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SawrniCard(
                child: Column(
                  children: [
                    _Metric(label: 'الدين الحالي', value: '${provider['debt_balance_iqd'] ?? 0} IQD'),
                    const Divider(),
                    _Metric(label: 'حد التعليق', value: '${provider['debt_threshold_iqd'] ?? 75000} IQD'),
                    const Divider(),
                    _Metric(label: 'الاشتراك', value: '${provider['subscription_plan'] ?? 'basic'}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: SawrniTheme.muted, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }
}
