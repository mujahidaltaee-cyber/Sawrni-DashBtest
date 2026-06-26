import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/app_theme.dart';
import '../core/session_store.dart';
import '../widgets/sawrni_scaffold.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});
  static const routeName = '/customer';

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
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
      final result = await _api.get('/customer/home', token: token);
      if (mounted) setState(() => _data = result);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'تعذر تحميل بيانات العميل.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = (_data?['categories'] as List?) ?? [];
    final providers = (_data?['featured_providers'] as List?) ?? [];

    return SawrniScaffold(
      title: 'واجهة العميل',
      actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const SawrniHero(
              badge: 'Customer App',
              title: 'اكتشف واحجز خدمات التصوير',
              subtitle: 'معلومات التواصل الحساسة لا تظهر قبل قواعد الحجز والدفع. العمولة والمنطق الداخلي يبقى داخل الخادم.',
            ),
            const SizedBox(height: 20),
            if (_loading) const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())),
            if (_error != null) Text(_error!, style: const TextStyle(color: SawrniTheme.danger, fontWeight: FontWeight.w800)),
            if (!_loading && _error == null) ...[
              const Text('الأقسام', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              for (final item in categories)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SawrniCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const Icon(Icons.camera_alt_outlined, color: SawrniTheme.purple),
                        const SizedBox(width: 12),
                        Expanded(child: Text('${item['title_ar'] ?? item['title_en']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text('مزودون موثوقون', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              if (providers.isEmpty)
                const SawrniCard(child: Text('لا توجد ملفات مزودين معتمدة بعد. المزودون لا يظهرون قبل موافقة الإدارة/COO.', style: TextStyle(color: SawrniTheme.muted, height: 1.7))),
              for (final item in providers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SawrniCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item['display_name'] ?? 'مزود خدمة'}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Text('${item['category'] ?? ''} · ${item['city'] ?? ''} · ${item['subscription_plan'] ?? ''}', style: const TextStyle(color: SawrniTheme.muted)),
                        const SizedBox(height: 8),
                        Text('${item['bio'] ?? item['public_portfolio_note'] ?? 'ملف معتمد بدون معلومات تواصل مباشرة.'}', style: const TextStyle(height: 1.6)),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
