import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';
import '../../core/network/sawrni_api_client.dart';
import '../../core/session/sawrni_session.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _api = SawrniApiClient();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    if (!SawrniSession.isLoggedIn) return [];
    final response = await _api.getJson('/mobile/customer/bookings', token: SawrniSession.token);
    final rows = response['rows'];
    if (rows is List) return rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حجوزاتي')),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (!SawrniSession.isLoggedIn) {
              return const _EmptyBookings(title: 'سجل دخولك أولاً', body: 'الحجوزات تظهر بعد تسجيل الدخول برقم الهاتف.');
            }
            if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return const _EmptyBookings(title: 'تعذر تحميل الحجوزات', body: 'تأكد من تشغيل Laravel وربط API.');
            final rows = snapshot.data ?? [];
            if (rows.isEmpty) return const _EmptyBookings(title: 'لا توجد حجوزات بعد', body: 'ابدأ باختيار خدمة وحجز مزود معتمد.');
            return ListView.builder(
              padding: const EdgeInsets.all(22),
              itemCount: rows.length,
              itemBuilder: (context, i) => _BookingCard(row: rows[i]),
            );
          },
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.row});
  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: SawrniBrand.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(row['booking_code']?.toString() ?? 'SWR', style: const TextStyle(color: SawrniBrand.purple, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(row['provider_name']?.toString() ?? 'مزود الخدمة', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('الحالة: ${row['status'] ?? '-'}', style: const TextStyle(color: SawrniBrand.muted)),
        const SizedBox(height: 8),
        Text('العربون: ${row['deposit_amount_iqd'] ?? 0} IQD · العمولة: ${row['platform_commission_iqd'] ?? 0} IQD'),
      ]),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center, style: const TextStyle(color: SawrniBrand.muted, height: 1.7)),
        ]),
      ),
    );
  }
}
