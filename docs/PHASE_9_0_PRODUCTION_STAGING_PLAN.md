# Sawrni Phase 9.0 — Production Staging Foundation

## Goal
Create one clean staging foundation for the real Sawrni system before public launch.

## Source-of-truth documents
- Phase 1: SRS v1.0 Final
- Phase 2: UI/UX Structure v1.0 Arabic
- Phase 3: Database & API Blueprint v1.0 Final AR/EN

## Required final structure
```text
backend-laravel/       Laravel REST API + PostgreSQL-ready backend
admin-dashboard/       Arabic-first RTL web admin dashboard
mobile-flutter/        Flutter Android/iOS mobile app
assets/brand/          Real Sawrni brand assets
docs/source/           Frozen project requirements and blueprints
deployment/            Staging/production deployment guides
tests/e2e/             Full system QA scenarios
shared-ui-spec/        Brand tokens, components and screen rules
```

## Non-negotiable product rules
- Provider accounts do not appear publicly before COO/super-admin approval.
- Customer and provider phone numbers stay hidden until deposit is paid.
- Chat opens only after deposit confirmation.
- Deposit is required before booking confirmation.
- Customer can edit booking within 3 hours from deposit payment.
- Customer can cancel with refundable deposit only within 1 hour from deposit payment.
- Platform commission is 15% of the full transaction value.
- Provider debt threshold is 75,000 IQD.
- Delivery files are private until admin/super-admin approval.
- Reviews are public only after admin/super-admin approval.
- Audit logs are required for sensitive admin and financial actions.

## Phase 9.0 output
This package locks repo structure, brand assets, staging checklist, shared tokens and QA flow. It does not pretend to finish the full product in one patch. It prepares the project for a real staging rebuild.
