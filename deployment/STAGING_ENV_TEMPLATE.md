# Sawrni Staging Environment Template

## Recommended staging domains
```text
api-staging.sawrni.com
admin-staging.sawrni.com
```

## Backend
- Runtime: PHP 8.3+
- Framework: Laravel REST API
- Database: PostgreSQL
- Storage: S3-compatible object storage
- Queue: Redis or database queue
- Notifications: Firebase Cloud Messaging

## Mobile
- Flutter Android/iOS
- Android internal testing through Google Play Console
- iOS testing through TestFlight

## Required environment values
```env
APP_ENV=staging
APP_DEBUG=false
APP_URL=https://api-staging.sawrni.com
FRONTEND_ADMIN_URL=https://admin-staging.sawrni.com
DB_CONNECTION=pgsql
STORAGE_DISK=s3
FCM_PROJECT_ID=
PAYMENT_GATEWAY_MODE=staging
SAWRNI_COMMISSION_PERCENT=15
SAWRNI_PROVIDER_DEBT_LIMIT_IQD=75000
SAWRNI_BOOKING_EDIT_WINDOW_HOURS=3
SAWRNI_BOOKING_REFUND_WINDOW_HOURS=1
```
