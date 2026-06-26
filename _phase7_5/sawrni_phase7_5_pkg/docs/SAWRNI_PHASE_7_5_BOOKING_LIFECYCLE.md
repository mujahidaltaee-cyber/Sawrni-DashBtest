# Sawrni Phase 7.5 — Booking Lifecycle + Deposit Rules

This phase moves Sawrni from app screens into the core business lifecycle.

## Included

- Customer booking request source
- Provider accept/reject state
- Deposit-required state
- Confirmed booking after deposit
- 15% platform commission calculation
- Customer edit deadline: 3 hours after deposit
- Customer cancel/refund deadline: 1 hour after deposit
- Deposit becomes non-refundable after cancel window
- Contact masking before confirmed booking
- Booking audit/event log table when Laravel backend exists
- Arabic-first UI using Sawrni identity and slogan: `استوديو كامل بجيبك`

## Production rules implemented

1. Provider/customer contact remains hidden until confirmed booking.
2. Booking is only confirmed after deposit is paid.
3. Platform commission is 15% of the full booking amount.
4. Customer can edit for 3 hours after deposit payment.
5. Customer can cancel with refundable deposit for 1 hour after deposit payment.
6. After that, deposit is non-refundable.
7. Actions are logged when Laravel backend exists.

## Apply

```bash
cd /workspaces/Sawrni-DashBtest

rm -rf _phase7_5
unzip -o Sawrni_Phase_7_5_Booking_Lifecycle_Deposit_Rules.zip -d _phase7_5

bash _phase7_5/sawrni_phase7_5_pkg/scripts/apply_phase7_5_booking_lifecycle_deposit.sh
```

## Next phase

Phase 7.6 — Delivery Upload + Signed Customer Access from mobile.
