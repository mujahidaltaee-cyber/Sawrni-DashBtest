# Sawrni Phase 7.3 — Customer Browse + Booking Flow

This phase adds the first real customer marketplace flow to the mobile app.

## Mobile screens

- Customer home with photography/editing/modeling entry points
- Approved provider list
- Provider detail screen
- Booking request form
- My bookings screen

## Backend endpoints

- GET `/api/v1/mobile/customer/categories`
- GET `/api/v1/mobile/customer/providers`
- GET `/api/v1/mobile/customer/providers/{id}`
- POST `/api/v1/mobile/customer/bookings`
- GET `/api/v1/mobile/customer/bookings`
- GET `/api/v1/mobile/marketplace/summary`

## Production business rules included

- Customers only see approved providers.
- Suspended providers and providers above the 75,000 IQD debt threshold are hidden.
- Platform commission is calculated as 15% of the full booking amount.
- Booking starts as `pending_provider_confirmation`.
- Deposit payment placeholder is created for later real payment integration.
- Customer edit/cancel timing fields are stored for future enforcement.

## Slogan

استوديو كامل بجيبك
