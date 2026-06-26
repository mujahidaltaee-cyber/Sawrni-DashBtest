import 'package:flutter/material.dart';

import '../../core/brand/sawrni_brand.dart';
import '../../core/business/sawrni_booking_rules.dart';
import '../../core/models/sawrni_booking.dart';
import '../shared/sawrni_ui.dart';

class BookingLifecycleScreen extends StatefulWidget {
  const BookingLifecycleScreen({super.key});

  @override
  State<BookingLifecycleScreen> createState() => _BookingLifecycleScreenState();
}

class _BookingLifecycleScreenState extends State<BookingLifecycleScreen> {
  int totalAmount = 120000;
  late SawrniBooking booking;

  @override
  void initState() {
    super.initState();
    _createDraftBooking();
  }

  void _createDraftBooking() {
    final deposit = SawrniBookingRules.suggestedDeposit(totalAmount);
    booking = SawrniBooking(
      serviceType: 'photography',
      providerName: 'Hussein Photo',
      titleAr: 'جلسة تصوير تخرج',
      location: 'Baghdad',
      scheduledAt: DateTime.now().add(const Duration(days: 2)),
      totalAmountIqd: totalAmount,
      depositAmountIqd: deposit,
      platformCommissionIqd: SawrniBookingRules.platformCommission(totalAmount),
      status: SawrniBookingStatus.draft,
      contactRevealed: false,
    );
  }

  void _sendRequest() {
    setState(() {
      booking = booking.copyWith(status: SawrniBookingStatus.pendingProvider);
    });
  }

  void _providerAccept() {
    setState(() {
      booking = booking.copyWith(status: SawrniBookingStatus.acceptedWaitingDeposit);
    });
  }

  void _payDepositPlaceholder() {
    final paidAt = DateTime.now();
    setState(() {
      booking = booking.copyWith(
        status: SawrniBookingStatus.confirmed,
        depositPaidAt: paidAt,
        customerEditDeadlineAt: SawrniBookingRules.customerEditDeadline(paidAt),
        depositRefundableUntil: SawrniBookingRules.depositRefundableUntil(paidAt),
        contactRevealed: true,
      );
    });
  }

  void _cancelBooking() {
    final refundable = SawrniBookingRules.canCustomerCancelWithRefund(
      now: DateTime.now(),
      depositPaidAt: booking.depositPaidAt,
    );
    setState(() {
      booking = booking.copyWith(
        status: refundable
            ? SawrniBookingStatus.customerCancelledRefundable
            : SawrniBookingStatus.customerCancelledNonRefundable,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final providerNet = SawrniBookingRules.providerNetAmount(booking.totalAmountIqd);
    final canEdit = SawrniBookingRules.canCustomerEdit(
      now: DateTime.now(),
      depositPaidAt: booking.depositPaidAt,
    );
    final canCancelRefund = SawrniBookingRules.canCustomerCancelWithRefund(
      now: DateTime.now(),
      depositPaidAt: booking.depositPaidAt,
    );

    return SawrniScaffold(
      title: 'دورة الحجز والعربون',
      subtitle: 'هذا هو منطق الإنتاج الأساسي: طلب حجز، قبول المزود، دفع العربون، ثم كشف التواصل والتعديل ضمن الوقت المسموح.',
      child: Column(
        children: [
          SawrniInfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('الخدمة', booking.titleAr),
                _row('مزود الخدمة', booking.providerName),
                _row('الحالة', booking.status.labelAr),
                _row('السعر الكلي', '${booking.totalAmountIqd} IQD'),
                _row('العربون', '${booking.depositAmountIqd} IQD'),
                _row('عمولة المنصة 15%', '${booking.platformCommissionIqd} IQD'),
                _row('صافي المزود', '$providerNet IQD'),
                _row('التواصل', booking.contactRevealed ? 'ظاهر بعد تأكيد الحجز' : 'مخفي قبل التأكيد'),
                if (booking.depositRefundableUntil != null)
                  _row('استرجاع العربون حتى', _format(booking.depositRefundableUntil!)),
                if (booking.customerEditDeadlineAt != null)
                  _row('تعديل العميل حتى', _format(booking.customerEditDeadlineAt!)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _statusNotice(canEdit: canEdit, canCancelRefund: canCancelRefund),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SawrniPrimaryButton(
                label: 'إرسال طلب الحجز',
                onPressed: booking.status == SawrniBookingStatus.draft ? _sendRequest : null,
              ),
              SawrniPrimaryButton(
                label: 'قبول المزود',
                color: SawrniBrand.success,
                onPressed: booking.status == SawrniBookingStatus.pendingProvider ? _providerAccept : null,
              ),
              SawrniPrimaryButton(
                label: 'دفع العربون',
                color: SawrniBrand.gold,
                onPressed: booking.status == SawrniBookingStatus.acceptedWaitingDeposit
                    ? _payDepositPlaceholder
                    : null,
              ),
              SawrniPrimaryButton(
                label: 'إلغاء الحجز',
                color: SawrniBrand.danger,
                onPressed: booking.status == SawrniBookingStatus.confirmed ? _cancelBooking : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusNotice({required bool canEdit, required bool canCancelRefund}) {
    return SawrniInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'قواعد الحجز',
            style: TextStyle(
              color: SawrniBrand.navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text('• يمكن للعميل تعديل الحجز لمدة 3 ساعات بعد دفع العربون.'),
          Text('• يمكن إلغاء الحجز مع استرجاع العربون لمدة ساعة واحدة بعد الدفع.'),
          Text('• بعد انتهاء ساعة الإلغاء يصبح العربون غير قابل للاسترجاع.'),
          Text('• يتم إخفاء وسائل التواصل قبل تأكيد الحجز.'),
          const SizedBox(height: 10),
          Text(
            'الآن: ${canEdit ? "التعديل متاح" : "التعديل غير متاح"} · ${canCancelRefund ? "إلغاء مع استرجاع متاح" : "الإلغاء المسترجع غير متاح"}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: SawrniBrand.muted)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  String _format(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
