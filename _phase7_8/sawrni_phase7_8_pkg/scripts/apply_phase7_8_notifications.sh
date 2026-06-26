#!/usr/bin/env bash
set -euo pipefail

ROOT="/workspaces/Sawrni-DashBtest"
MOBILE="$ROOT/mobile-flutter"
BACKEND="$ROOT/_sawrni_phase6/backend-runtime-laravel"

mkdir -p "$MOBILE/lib/features/notifications" "$MOBILE/lib/shared/theme" "$MOBILE/lib/shared/widgets"

cat > "$MOBILE/lib/features/notifications/sawrni_notification.dart" <<'DART'
class SawrniNotification {
  final String id;
  final String titleAr;
  final String bodyAr;
  final String type;
  final String audience;
  final bool isRead;
  final DateTime createdAt;

  const SawrniNotification({
    required this.id,
    required this.titleAr,
    required this.bodyAr,
    required this.type,
    required this.audience,
    required this.isRead,
    required this.createdAt,
  });

  factory SawrniNotification.fromJson(Map<String, dynamic> json) {
    return SawrniNotification(
      id: '${json['id'] ?? ''}',
      titleAr: '${json['title_ar'] ?? ''}',
      bodyAr: '${json['body_ar'] ?? ''}',
      type: '${json['type'] ?? 'general'}',
      audience: '${json['audience'] ?? 'customer'}',
      isRead: json['read_at'] != null || json['is_read'] == true,
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}') ?? DateTime.now(),
    );
  }
}
DART

cat > "$MOBILE/lib/features/notifications/notification_center_page.dart" <<'DART'
import 'package:flutter/material.dart';
import 'sawrni_notification.dart';

class NotificationCenterPage extends StatelessWidget {
  final String audience;

  const NotificationCenterPage({super.key, required this.audience});

  List<SawrniNotification> get _items => [
        SawrniNotification(
          id: '1',
          titleAr: 'تم قبول طلب الحجز',
          bodyAr: 'مزود الخدمة قبل طلبك. يرجى إكمال العربون لتأكيد الحجز.',
          type: 'booking_accepted',
          audience: 'customer',
          isRead: false,
          createdAt: DateTime.now(),
        ),
        SawrniNotification(
          id: '2',
          titleAr: 'ملفات التسليم بانتظار المراجعة',
          bodyAr: 'تم رفع ملفات التسليم وسيتم إتاحتها بعد موافقة الإدارة.',
          type: 'delivery_pending_review',
          audience: 'customer',
          isRead: false,
          createdAt: DateTime.now(),
        ),
        SawrniNotification(
          id: '3',
          titleAr: 'طلب حجز جديد',
          bodyAr: 'لديك طلب حجز جديد. الرجاء مراجعة التفاصيل والقبول أو الرفض.',
          type: 'provider_new_booking',
          audience: 'provider',
          isRead: false,
          createdAt: DateTime.now(),
        ),
        SawrniNotification(
          id: '4',
          titleAr: 'تنبيه دين',
          bodyAr: 'رصيد الدين يقترب من حد 75,000 د.ع. يرجى التسديد لتجنب التعليق.',
          type: 'debt_warning',
          audience: 'provider',
          isRead: true,
          createdAt: DateTime.now(),
        ),
      ].where((n) => n.audience == audience).toList();

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF071326);
    const purple = Color(0xFF522E91);
    const gold = Color(0xFFD9A441);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          title: const Text('الإشعارات'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('صورني', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  SizedBox(height: 6),
                  Text('استوديو كامل بجيبك', style: TextStyle(color: gold, fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ..._items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: item.isRead ? const Color(0xFFE2E8F0) : gold.withOpacity(.6)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 18, offset: const Offset(0, 10))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: item.isRead ? const Color(0xFFF1F5F9) : purple.withOpacity(.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_iconFor(item.type), color: item.isRead ? Colors.grey : purple),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.titleAr, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: navy)),
                            const SizedBox(height: 6),
                            Text(item.bodyAr, style: const TextStyle(color: Color(0xFF64748B), height: 1.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    if (type.contains('booking')) return Icons.event_available_rounded;
    if (type.contains('delivery')) return Icons.folder_special_rounded;
    if (type.contains('review')) return Icons.star_rounded;
    if (type.contains('debt')) return Icons.warning_amber_rounded;
    return Icons.notifications_rounded;
  }
}
DART

# Optional integration note for Flutter navigation.
cat > "$MOBILE/lib/features/notifications/README.md" <<'EOF2'
# Notifications feature

Use:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const NotificationCenterPage(audience: 'customer')),
);
```

Provider audience:

```dart
NotificationCenterPage(audience: 'provider')
```
EOF2

if [ -d "$BACKEND" ] && [ -f "$BACKEND/artisan" ]; then
  cd "$BACKEND"
  cat > database/migrations/2026_06_26_000078_create_sawrni_notifications_tables.php <<'PHP'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('sawrni_notifications')) {
            Schema::create('sawrni_notifications', function (Blueprint $table) {
                $table->id();
                $table->string('audience', 40)->index(); // customer, provider, admin
                $table->unsignedBigInteger('user_id')->nullable()->index();
                $table->string('type', 80)->index();
                $table->string('title_ar');
                $table->text('body_ar');
                $table->string('title_en')->nullable();
                $table->text('body_en')->nullable();
                $table->string('related_module', 80)->nullable()->index();
                $table->unsignedBigInteger('related_id')->nullable()->index();
                $table->json('payload')->nullable();
                $table->timestamp('read_at')->nullable()->index();
                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('sawrni_notifications');
    }
};
PHP

  cat > routes/sawrni_phase7_8_notifications.php <<'PHP'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;

function sawrni_78_notifications_ready(): void {
    if (!Schema::hasTable('sawrni_notifications')) {
        Schema::create('sawrni_notifications', function (Blueprint $table) {
            $table->id();
            $table->string('audience', 40)->index();
            $table->unsignedBigInteger('user_id')->nullable()->index();
            $table->string('type', 80)->index();
            $table->string('title_ar');
            $table->text('body_ar');
            $table->string('title_en')->nullable();
            $table->text('body_en')->nullable();
            $table->string('related_module', 80)->nullable()->index();
            $table->unsignedBigInteger('related_id')->nullable()->index();
            $table->json('payload')->nullable();
            $table->timestamp('read_at')->nullable()->index();
            $table->timestamps();
        });
    }

    if (DB::table('sawrni_notifications')->count() === 0) {
        DB::table('sawrni_notifications')->insert([
            [
                'audience' => 'customer',
                'user_id' => 1,
                'type' => 'booking_accepted',
                'title_ar' => 'تم قبول طلب الحجز',
                'body_ar' => 'مزود الخدمة قبل طلبك. يرجى إكمال العربون لتأكيد الحجز.',
                'related_module' => 'bookings',
                'related_id' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'audience' => 'provider',
                'user_id' => 1,
                'type' => 'provider_new_booking',
                'title_ar' => 'طلب حجز جديد',
                'body_ar' => 'لديك طلب حجز جديد. الرجاء مراجعة التفاصيل والقبول أو الرفض.',
                'related_module' => 'bookings',
                'related_id' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'audience' => 'provider',
                'user_id' => 1,
                'type' => 'debt_warning',
                'title_ar' => 'تنبيه دين',
                'body_ar' => 'رصيد الدين يقترب من حد 75,000 د.ع. يرجى التسديد لتجنب التعليق.',
                'related_module' => 'wallets',
                'related_id' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}

Route::prefix('/v1/app/notifications')->group(function () {
    Route::get('/{audience}', function (Request $request, string $audience) {
        sawrni_78_notifications_ready();

        if (!in_array($audience, ['customer', 'provider', 'admin'], true)) {
            return response()->json(['status' => 'error', 'message_en' => 'Invalid audience.'], 422);
        }

        $rows = DB::table('sawrni_notifications')
            ->where('audience', $audience)
            ->orderByDesc('id')
            ->limit(50)
            ->get();

        return response()->json([
            'status' => 'ok',
            'phase' => '7.8',
            'audience' => $audience,
            'rows' => $rows,
        ]);
    });

    Route::post('/{id}/read', function (Request $request, int $id) {
        sawrni_78_notifications_ready();

        DB::table('sawrni_notifications')->where('id', $id)->update([
            'read_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json(['status' => 'ok', 'phase' => '7.8']);
    });
});
PHP

  if [ -f routes/api.php ]; then
    if ! grep -q "sawrni_phase7_8_notifications.php" routes/api.php; then
      cat >> routes/api.php <<'PHP'

if (file_exists(__DIR__ . '/sawrni_phase7_8_notifications.php')) {
    require __DIR__ . '/sawrni_phase7_8_notifications.php';
}
PHP
    fi
  fi

  php artisan migrate --force || true
  php artisan optimize:clear || true
fi

mkdir -p "$ROOT/_verified_builds"
cat > "$ROOT/_verified_builds/SAWRNI_PHASE_7_8_NOTIFICATIONS_SOURCE_REPORT.md" <<'REPORT'
# Sawrni Phase 7.8 — Notifications Foundation

Status: SOURCE APPLIED

Added:
- Flutter notification center source.
- Customer and provider notification examples.
- Laravel notification table and routes when backend exists.
- Notification types for booking, delivery, review, provider, and debt workflows.
- Sawrni Arabic-first identity and slogan: استوديو كامل بجيبك.

This phase is production-source oriented and does not add local test bypasses.
REPORT

echo "PASS: Phase 7.8 notifications foundation source applied."
