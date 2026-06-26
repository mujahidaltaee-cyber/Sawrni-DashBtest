import '../config/app_config.dart';

class SawrniBookingRules {
  static int platformCommission(int totalAmountIqd) {
    return (totalAmountIqd * AppConfig.platformCommissionPercent / 100).round();
  }

  static int providerNetAmount(int totalAmountIqd) {
    return totalAmountIqd - platformCommission(totalAmountIqd);
  }

  static int suggestedDeposit(int totalAmountIqd) {
    // Placeholder deposit logic. Can later become category-based from backend.
    final deposit = (totalAmountIqd * 0.30).round();
    return deposit < 10000 ? 10000 : deposit;
  }

  static DateTime customerEditDeadline(DateTime depositPaidAt) {
    return depositPaidAt.add(
      const Duration(hours: AppConfig.customerEditWindowHoursAfterDeposit),
    );
  }

  static DateTime depositRefundableUntil(DateTime depositPaidAt) {
    return depositPaidAt.add(
      const Duration(hours: AppConfig.customerCancelWindowHoursAfterDeposit),
    );
  }

  static bool canCustomerEdit({
    required DateTime now,
    required DateTime? depositPaidAt,
  }) {
    if (depositPaidAt == null) return false;
    return now.isBefore(customerEditDeadline(depositPaidAt));
  }

  static bool canCustomerCancelWithRefund({
    required DateTime now,
    required DateTime? depositPaidAt,
  }) {
    if (depositPaidAt == null) return false;
    return now.isBefore(depositRefundableUntil(depositPaidAt));
  }

  static bool shouldSuspendProviderForDebt(int debtBalanceIqd) {
    return debtBalanceIqd >= AppConfig.debtThresholdIqd;
  }

  static String maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length <= 4) return '****';
    return '${digits.substring(0, 3)}****${digits.substring(digits.length - 2)}';
  }
}
