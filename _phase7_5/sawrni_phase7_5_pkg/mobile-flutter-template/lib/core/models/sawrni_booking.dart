enum SawrniBookingStatus {
  draft,
  pendingProvider,
  rejectedByProvider,
  acceptedWaitingDeposit,
  confirmed,
  customerCancelledRefundable,
  customerCancelledNonRefundable,
  completed,
}

extension SawrniBookingStatusLabel on SawrniBookingStatus {
  String get labelAr {
    switch (this) {
      case SawrniBookingStatus.draft:
        return 'مسودة';
      case SawrniBookingStatus.pendingProvider:
        return 'بانتظار موافقة المزود';
      case SawrniBookingStatus.rejectedByProvider:
        return 'مرفوض من المزود';
      case SawrniBookingStatus.acceptedWaitingDeposit:
        return 'بانتظار دفع العربون';
      case SawrniBookingStatus.confirmed:
        return 'حجز مؤكد';
      case SawrniBookingStatus.customerCancelledRefundable:
        return 'ملغي مع استرجاع العربون';
      case SawrniBookingStatus.customerCancelledNonRefundable:
        return 'ملغي بدون استرجاع العربون';
      case SawrniBookingStatus.completed:
        return 'مكتمل';
    }
  }

  String get apiValue {
    switch (this) {
      case SawrniBookingStatus.draft:
        return 'draft';
      case SawrniBookingStatus.pendingProvider:
        return 'pending_provider';
      case SawrniBookingStatus.rejectedByProvider:
        return 'rejected_by_provider';
      case SawrniBookingStatus.acceptedWaitingDeposit:
        return 'accepted_waiting_deposit';
      case SawrniBookingStatus.confirmed:
        return 'confirmed';
      case SawrniBookingStatus.customerCancelledRefundable:
        return 'customer_cancelled_refundable';
      case SawrniBookingStatus.customerCancelledNonRefundable:
        return 'customer_cancelled_nonrefundable';
      case SawrniBookingStatus.completed:
        return 'completed';
    }
  }
}

class SawrniBooking {
  final int? id;
  final String serviceType;
  final String providerName;
  final String titleAr;
  final String location;
  final DateTime? scheduledAt;
  final int totalAmountIqd;
  final int depositAmountIqd;
  final int platformCommissionIqd;
  final SawrniBookingStatus status;
  final DateTime? depositPaidAt;
  final DateTime? customerEditDeadlineAt;
  final DateTime? depositRefundableUntil;
  final String? providerRejectionReason;
  final bool contactRevealed;

  const SawrniBooking({
    this.id,
    required this.serviceType,
    required this.providerName,
    required this.titleAr,
    required this.location,
    this.scheduledAt,
    required this.totalAmountIqd,
    required this.depositAmountIqd,
    required this.platformCommissionIqd,
    required this.status,
    this.depositPaidAt,
    this.customerEditDeadlineAt,
    this.depositRefundableUntil,
    this.providerRejectionReason,
    this.contactRevealed = false,
  });

  SawrniBooking copyWith({
    int? id,
    String? serviceType,
    String? providerName,
    String? titleAr,
    String? location,
    DateTime? scheduledAt,
    int? totalAmountIqd,
    int? depositAmountIqd,
    int? platformCommissionIqd,
    SawrniBookingStatus? status,
    DateTime? depositPaidAt,
    DateTime? customerEditDeadlineAt,
    DateTime? depositRefundableUntil,
    String? providerRejectionReason,
    bool? contactRevealed,
  }) {
    return SawrniBooking(
      id: id ?? this.id,
      serviceType: serviceType ?? this.serviceType,
      providerName: providerName ?? this.providerName,
      titleAr: titleAr ?? this.titleAr,
      location: location ?? this.location,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      totalAmountIqd: totalAmountIqd ?? this.totalAmountIqd,
      depositAmountIqd: depositAmountIqd ?? this.depositAmountIqd,
      platformCommissionIqd: platformCommissionIqd ?? this.platformCommissionIqd,
      status: status ?? this.status,
      depositPaidAt: depositPaidAt ?? this.depositPaidAt,
      customerEditDeadlineAt: customerEditDeadlineAt ?? this.customerEditDeadlineAt,
      depositRefundableUntil: depositRefundableUntil ?? this.depositRefundableUntil,
      providerRejectionReason: providerRejectionReason ?? this.providerRejectionReason,
      contactRevealed: contactRevealed ?? this.contactRevealed,
    );
  }
}
