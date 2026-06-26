enum ProviderBookingStatus {
  pendingProviderReview,
  providerAccepted,
  providerRejected,
  customerPaidDeposit,
  inProgress,
  delivered,
  completed,
  cancelled,
}

class ProviderBooking {
  ProviderBooking({
    required this.id,
    required this.reference,
    required this.titleAr,
    required this.titleEn,
    required this.status,
    required this.customerName,
    required this.maskedPhone,
    required this.serviceType,
    required this.totalAmountIqd,
    required this.depositAmountIqd,
    required this.finalPriceIqd,
    required this.platformCommissionIqd,
    required this.scheduledAt,
    required this.notes,
  });

  final int id;
  final String reference;
  final String titleAr;
  final String titleEn;
  final String status;
  final String customerName;
  final String maskedPhone;
  final String serviceType;
  final int totalAmountIqd;
  final int depositAmountIqd;
  final int finalPriceIqd;
  final int platformCommissionIqd;
  final String scheduledAt;
  final String notes;

  factory ProviderBooking.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '0') ?? 0;
    }

    return ProviderBooking(
      id: asInt(json['id']),
      reference: (json['reference'] ?? 'SWR-${json['id'] ?? ''}').toString(),
      titleAr: (json['title_ar'] ?? 'حجز جديد').toString(),
      titleEn: (json['title_en'] ?? 'New booking').toString(),
      status: (json['status'] ?? 'pending_provider_review').toString(),
      customerName: (json['customer_name'] ?? json['party'] ?? 'عميل').toString(),
      maskedPhone: (json['masked_phone'] ?? '07*********').toString(),
      serviceType: (json['service_type'] ?? 'photography').toString(),
      totalAmountIqd: asInt(json['total_amount_iqd'] ?? json['amount_iqd']),
      depositAmountIqd: asInt(json['deposit_amount_iqd']),
      finalPriceIqd: asInt(json['final_price_iqd']),
      platformCommissionIqd: asInt(json['platform_commission_iqd']),
      scheduledAt: (json['scheduled_at'] ?? 'غير محدد').toString(),
      notes: (json['notes'] ?? '').toString(),
    );
  }

  String get statusAr {
    switch (status) {
      case 'pending_provider_review':
        return 'بانتظار رد مزود الخدمة';
      case 'provider_accepted':
        return 'تم القبول';
      case 'provider_rejected':
        return 'تم الرفض';
      case 'customer_paid_deposit':
        return 'تم دفع العربون';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'delivered':
        return 'تم التسليم';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}
