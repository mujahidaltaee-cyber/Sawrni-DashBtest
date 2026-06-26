import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';
import 'provider_booking_model.dart';
import 'provider_booking_service.dart';

class ProviderBookingDetailsScreen extends StatefulWidget {
  const ProviderBookingDetailsScreen({super.key, required this.bookingId});

  final int bookingId;

  @override
  State<ProviderBookingDetailsScreen> createState() => _ProviderBookingDetailsScreenState();
}

class _ProviderBookingDetailsScreenState extends State<ProviderBookingDetailsScreen> {
  final ProviderBookingService _service = ProviderBookingService();
  late Future<ProviderBooking> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchBookingDetails(widget.bookingId);
  }

  Future<void> _accept() async {
    setState(() => _busy = true);
    try {
      await _service.acceptBooking(widget.bookingId);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم قبول الحجز.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('سبب الرفض'),
          content: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'اكتب السبب ليظهر في السجلات الداخلية',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(SawrniBrand.danger)),
              child: const Text('رفض'),
            ),
          ],
        ),
      ),
    );

    if (reason == null || reason.isEmpty) return;

    setState(() => _busy = true);
    try {
      await _service.rejectBooking(widget.bookingId, reason);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفض الحجز.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(SawrniBrand.softBg),
        appBar: AppBar(
          title: const Text('تفاصيل الحجز'),
          backgroundColor: const Color(SawrniBrand.softBg),
          foregroundColor: const Color(SawrniBrand.text),
          elevation: 0,
        ),
        body: FutureBuilder<ProviderBooking>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final booking = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.titleAr, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(SawrniBrand.text))),
                      const SizedBox(height: 10),
                      Text('${booking.reference} · ${booking.statusAr}', style: const TextStyle(color: Color(SawrniBrand.purple), fontWeight: FontWeight.w900)),
                      const SizedBox(height: 22),
                      _Field(label: 'العميل', value: booking.customerName),
                      _Field(label: 'الهاتف', value: booking.maskedPhone),
                      _Field(label: 'نوع الخدمة', value: booking.serviceType),
                      _Field(label: 'الموعد', value: booking.scheduledAt),
                      _Field(label: 'المبلغ الكلي', value: '${booking.totalAmountIqd} IQD'),
                      _Field(label: 'العربون', value: '${booking.depositAmountIqd} IQD'),
                      _Field(label: 'السعر النهائي', value: '${booking.finalPriceIqd} IQD'),
                      _Field(label: 'عمولة المنصة 15%', value: '${booking.platformCommissionIqd} IQD'),
                      _Field(label: 'ملاحظات', value: booking.notes),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _busy ? null : _accept,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(SawrniBrand.success),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              child: const Text('قبول الحجز', style: TextStyle(fontWeight: FontWeight.w900)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _busy ? null : _reject,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(SawrniBrand.danger),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              child: const Text('رفض الحجز', style: TextStyle(fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(SawrniBrand.softBg),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(SawrniBrand.muted), fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(color: Color(SawrniBrand.text), fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
