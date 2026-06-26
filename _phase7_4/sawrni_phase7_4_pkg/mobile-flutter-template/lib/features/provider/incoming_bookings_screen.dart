import 'package:flutter/material.dart';
import '../../core/brand/sawrni_brand.dart';
import 'provider_booking_details_screen.dart';
import 'provider_booking_model.dart';
import 'provider_booking_service.dart';

class IncomingBookingsScreen extends StatefulWidget {
  const IncomingBookingsScreen({super.key});

  @override
  State<IncomingBookingsScreen> createState() => _IncomingBookingsScreenState();
}

class _IncomingBookingsScreenState extends State<IncomingBookingsScreen> {
  final ProviderBookingService _service = ProviderBookingService();
  late Future<List<ProviderBooking>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchIncomingBookings();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _service.fetchIncomingBookings();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(SawrniBrand.softBg),
        appBar: AppBar(
          title: const Text('طلبات الحجز'),
          backgroundColor: const Color(SawrniBrand.softBg),
          foregroundColor: const Color(SawrniBrand.text),
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<ProviderBooking>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _ErrorCard(message: snapshot.error.toString(), onRetry: _refresh),
                  ],
                );
              }

              final bookings = snapshot.data ?? const [];
              if (bookings.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: const [
                    _EmptyCard(),
                  ],
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return _BookingCard(
                    booking: booking,
                    onOpen: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProviderBookingDetailsScreen(bookingId: booking.id),
                        ),
                      );
                      _refresh();
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.onOpen});

  final ProviderBooking booking;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(booking.titleAr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(SawrniBrand.text))),
          const SizedBox(height: 8),
          Text('${booking.reference} · ${booking.customerName} · ${booking.maskedPhone}',
              style: const TextStyle(color: Color(SawrniBrand.muted), fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(booking.notes, style: const TextStyle(color: Color(SawrniBrand.muted), height: 1.6)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(text: booking.statusAr),
              _Chip(text: '${booking.totalAmountIqd} IQD'),
              _Chip(text: booking.scheduledAt),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onOpen,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text('عرض التفاصيل والرد'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(SawrniBrand.purple).withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(color: Color(SawrniBrand.purple), fontWeight: FontWeight.w800)),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: const Column(
        children: [
          Text('لا توجد طلبات حالياً', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Text('عند وصول طلبات جديدة ستظهر هنا.', style: TextStyle(color: Color(SawrniBrand.muted))),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          const Text('تعذر تحميل الطلبات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Color(SawrniBrand.muted))),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
