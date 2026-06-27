# Sawrni Full Staging QA Checklist

## Identity and language
- [ ] Splash uses real square logo.
- [ ] App/admin use #06162F navy, #D7A63A gold, #492981 purple.
- [ ] Arabic RTL works across app and admin.
- [ ] English LTR works without layout breakage.
- [ ] Slogan appears: استوديو كامل بجيبك.

## Auth
- [ ] Customer phone OTP login works.
- [ ] Provider phone OTP login works.
- [ ] Admin login works.
- [ ] Tokens persist securely.
- [ ] Logout clears session.

## Provider approval
- [ ] Provider registers as photographer.
- [ ] Provider registers as editor.
- [ ] Provider registers as model.
- [ ] New provider stays hidden from customer app.
- [ ] Provider appears in admin pending approvals.
- [ ] COO/super-admin approves provider.
- [ ] Approved provider appears in customer app.
- [ ] Rejected provider sees rejection state.

## Customer booking
- [ ] Customer browses service categories.
- [ ] Models show in tiny-square grid.
- [ ] Customer opens provider profile.
- [ ] Phone/contact hidden before deposit.
- [ ] Customer selects package/date/time/location.
- [ ] Customer creates booking/deposit pending.
- [ ] Deposit confirmation creates confirmed booking.
- [ ] Contact and chat unlock after deposit.

## Provider booking
- [ ] Provider sees incoming booking.
- [ ] Provider accepts booking.
- [ ] Customer sees accepted state.
- [ ] Provider rejects booking with required reason.
- [ ] Admin can see booking status history.

## Booking rules
- [ ] Edit allowed within 3 hours after deposit.
- [ ] Edit disabled after 3 hours.
- [ ] Refundable cancel allowed within 1 hour.
- [ ] After 1 hour, deposit becomes non-refundable.
- [ ] Location non-compliance cancellation reason exists.

## Payments and wallet
- [ ] Total price = deposit + remaining.
- [ ] Commission = total * 15%.
- [ ] Provider net = total * 85%.
- [ ] Wallet ledger entries are immutable.
- [ ] Provider debt warning appears before threshold.
- [ ] Suspension is available at 75,000 IQD debt.

## Delivery
- [ ] Provider uploads final delivery batch.
- [ ] Customer cannot access pending delivery.
- [ ] Admin approves delivery.
- [ ] Customer can access approved delivery.
- [ ] Rejected delivery returns reason to provider.

## Reviews
- [ ] Customer submits review after completed booking.
- [ ] Review is pending moderation.
- [ ] Admin approves review.
- [ ] Approved rating updates provider public rating.
- [ ] Rejected review does not appear publicly.

## Notifications
- [ ] New booking notification.
- [ ] Deposit paid notification.
- [ ] Booking accepted/rejected notification.
- [ ] Reminder before session.
- [ ] Delivery uploaded/approved notification.
- [ ] Review approved/rejected notification.
- [ ] Debt warning/suspension notification.

## Admin dashboard
- [ ] Dashboard KPIs load from backend.
- [ ] Provider approvals load and actions work.
- [ ] Bookings list loads and status filters work.
- [ ] Payments, wallets and debts load.
- [ ] Delivery approval works.
- [ ] Review approval works.
- [ ] Admin permission matrix works.
- [ ] Audit logs record sensitive actions.
