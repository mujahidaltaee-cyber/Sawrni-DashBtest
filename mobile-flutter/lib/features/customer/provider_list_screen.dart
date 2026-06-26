import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';
import '../../core/network/sawrni_api_client.dart';

class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({super.key});

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final _api = SawrniApiClient();
  late Future<List<Map<String, dynamic>>> _future;
  String _serviceType = 'photography';
  String _title = 'مزودو الخدمة';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    _serviceType = (args['service_type'] ?? 'photography').toString();
    _title = (args['title'] ?? 'مزودو الخدمة').toString();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final response = await _api.getJson('/mobile/customer/providers?service_type=$_serviceType');
    final rows = response['rows'];
    if (rows is List) return rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _StateBox(
                title: 'تعذر تحميل المزودين',
                body: 'تأكد من تشغيل Laravel وتحديث رابط API للتطبيق.',
                action: 'إعادة المحاولة',
                onTap: () => setState(() => _future = _load()),
              );
            }
            final rows = snapshot.data ?? [];
            if (rows.isEmpty) {
              return const _StateBox(
                title: 'لا يوجد مزودون ظاهرون حالياً',
                body: 'المزودون لا يظهرون للعملاء إلا بعد موافقة الإدارة/COO.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(22),
              itemCount: rows.length,
              itemBuilder: (context, index) => _ProviderCard(provider: rows[index]),
            );
          },
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({required this.provider});
  final Map<String, dynamic> provider;

  @override
  Widget build(BuildContext context) {
    final price = provider['starting_price_iqd']?.toString() ?? '-';
    final rating = provider['rating']?.toString() ?? '-';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: SawrniBrand.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(provider['display_name']?.toString() ?? 'Provider', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: SawrniBrand.cream, borderRadius: BorderRadius.circular(18)),
            child: const Text('approved', style: TextStyle(color: SawrniBrand.purple, fontWeight: FontWeight.w900)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(provider['bio_ar']?.toString() ?? provider['bio_en']?.toString() ?? '', style: const TextStyle(color: SawrniBrand.muted, height: 1.7)),
        const SizedBox(height: 12),
        Text('المدينة: ${provider['city'] ?? '-'} · التقييم: $rating · يبدأ من: $price IQD', style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamed('/customer/provider-details', arguments: provider),
              child: const Text('عرض'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/customer/booking', arguments: provider),
              child: const Text('احجز'),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _StateBox extends StatelessWidget {
  const _StateBox({required this.title, required this.body, this.action, this.onTap});
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: SawrniBrand.line)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center, style: const TextStyle(color: SawrniBrand.muted, height: 1.7)),
            if (action != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onTap, child: Text(action!)),
            ],
          ]),
        ),
      ),
    );
  }
}
