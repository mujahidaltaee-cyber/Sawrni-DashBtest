# Sawrni Phase 7.3 — Customer Browse + Booking Flow

هذه المرحلة تنقل التطبيق من واجهة أساس إلى تدفق حقيقي للعميل:

- اختيار نوع الخدمة: تصوير / تعديل صور / مودلز
- عرض مزودي الخدمة المعتمدين فقط
- تفاصيل مزود الخدمة
- إرسال طلب حجز
- حساب عمولة المنصة 15%
- تخزين العربون والسعر النهائي ونافذة تعديل/إلغاء العميل
- صفحة حجوزاتي

الشعار المعتمد:

استوديو كامل بجيبك

## التطبيق

الكود يوضع في:

`mobile-flutter`

## Laravel

المسارات الجديدة:

- `/api/v1/mobile/customer/categories`
- `/api/v1/mobile/customer/providers`
- `/api/v1/mobile/customer/providers/{id}`
- `/api/v1/mobile/customer/bookings`
- `/api/v1/mobile/marketplace/summary`
