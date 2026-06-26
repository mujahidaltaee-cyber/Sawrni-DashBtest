# Sawrni Phase 7.7 — Reviews + Rating Approval Before Publish

This phase adds production review workflow source:

- Customer submits a review.
- Review remains `pending_review`.
- Review is not public until admin/COO/super-admin approves it.
- Rejected reviews remain internal for audit and are not published.
- Provider public rating should be calculated only from approved reviews.
- Approval/rejection decisions are recorded in audit logs.

Brand slogan:

> استوديو كامل بجيبك
