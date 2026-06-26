<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;

if (!function_exists('sawrni_phase77_review_tables_ready')) {
    function sawrni_phase77_review_tables_ready(): void
    {
        if (!Schema::hasTable('sawrni_reviews')) {
            Schema::create('sawrni_reviews', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('booking_id')->nullable()->index();
                $table->unsignedBigInteger('customer_id')->nullable()->index();
                $table->unsignedBigInteger('provider_id')->nullable()->index();
                $table->unsignedTinyInteger('rating')->default(5);
                $table->text('comment')->nullable();
                $table->string('status')->default('pending_review')->index();
                $table->text('admin_note')->nullable();
                $table->unsignedBigInteger('approved_by')->nullable()->index();
                $table->timestamp('approved_at')->nullable();
                $table->timestamp('rejected_at')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('sawrni_review_audit_logs')) {
            Schema::create('sawrni_review_audit_logs', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('review_id')->nullable()->index();
                $table->unsignedBigInteger('actor_id')->nullable()->index();
                $table->string('actor_role')->nullable();
                $table->string('action')->index();
                $table->json('payload')->nullable();
                $table->string('ip_address')->nullable();
                $table->text('user_agent')->nullable();
                $table->timestamps();
            });
        }
    }
}

if (!function_exists('sawrni_phase77_audit_review')) {
    function sawrni_phase77_audit_review(Request $request, ?int $reviewId, string $action, array $payload = []): void
    {
        sawrni_phase77_review_tables_ready();
        DB::table('sawrni_review_audit_logs')->insert([
            'review_id' => $reviewId,
            'actor_id' => $payload['actor_id'] ?? null,
            'actor_role' => $payload['actor_role'] ?? 'system',
            'action' => $action,
            'payload' => json_encode($payload, JSON_UNESCAPED_UNICODE),
            'ip_address' => $request->ip(),
            'user_agent' => substr((string) $request->userAgent(), 0, 1000),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}

if (!function_exists('sawrni_phase77_admin_guard')) {
    function sawrni_phase77_admin_guard(Request $request) {
        // Production integration point: replace with the final admin session middleware.
        // For now, reject empty admin calls and allow existing Bearer-token admin flow.
        if (!$request->bearerToken()) {
            return response()->json([
                'status' => 'error',
                'message_ar' => 'يتطلب هذا الإجراء تسجيل دخول الإدارة.',
                'message_en' => 'Admin authentication is required.',
                'phase' => '7.7',
            ], 401);
        }
        return null;
    }
}

Route::get('/v1/reviews/config', function () {
    return response()->json([
        'status' => 'ok',
        'phase' => '7.7',
        'rules' => [
            'reviews_public_only_after_admin_approval' => true,
            'provider_rating_uses_approved_reviews_only' => true,
            'rejected_reviews_kept_for_audit' => true,
            'slogan_ar' => 'استوديو كامل بجيبك',
        ],
    ]);
});

Route::prefix('/v1/app/reviews')->group(function () {
    Route::post('/submit', function (Request $request) {
        sawrni_phase77_review_tables_ready();

        $data = $request->validate([
            'booking_id' => ['nullable', 'integer'],
            'customer_id' => ['nullable', 'integer'],
            'provider_id' => ['required', 'integer'],
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'comment' => ['nullable', 'string', 'max:2000'],
        ]);

        $id = DB::table('sawrni_reviews')->insertGetId([
            'booking_id' => $data['booking_id'] ?? null,
            'customer_id' => $data['customer_id'] ?? null,
            'provider_id' => $data['provider_id'],
            'rating' => $data['rating'],
            'comment' => $data['comment'] ?? null,
            'status' => 'pending_review',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        sawrni_phase77_audit_review($request, $id, 'customer_review_submitted_pending_approval', [
            'actor_role' => 'customer',
            'customer_id' => $data['customer_id'] ?? null,
            'provider_id' => $data['provider_id'],
            'rating' => $data['rating'],
        ]);

        return response()->json([
            'status' => 'ok',
            'review_id' => $id,
            'review_status' => 'pending_review',
            'message_ar' => 'تم إرسال التقييم وينتظر موافقة الإدارة قبل النشر.',
            'message_en' => 'Review submitted and is waiting for admin approval before publishing.',
            'phase' => '7.7',
        ], 201);
    });

    Route::get('/my', function (Request $request) {
        sawrni_phase77_review_tables_ready();
        $customerId = $request->query('customer_id');
        $q = DB::table('sawrni_reviews')->orderByDesc('id');
        if ($customerId) {
            $q->where('customer_id', $customerId);
        }
        return response()->json([
            'status' => 'ok',
            'rows' => $q->limit(50)->get(),
            'phase' => '7.7',
        ]);
    });
});

Route::get('/v1/public/providers/{providerId}/reviews', function (int $providerId) {
    sawrni_phase77_review_tables_ready();
    $rows = DB::table('sawrni_reviews')
        ->where('provider_id', $providerId)
        ->where('status', 'approved')
        ->orderByDesc('approved_at')
        ->limit(50)
        ->get(['id', 'provider_id', 'rating', 'comment', 'approved_at']);

    $avg = $rows->count() ? round($rows->avg('rating'), 2) : null;

    return response()->json([
        'status' => 'ok',
        'provider_id' => $providerId,
        'published_reviews_count' => $rows->count(),
        'published_rating_average' => $avg,
        'rows' => $rows,
        'phase' => '7.7',
    ]);
});

Route::prefix('/v1/admin-v10/reviews')->group(function () {
    Route::get('/', function (Request $request) {
        if ($guard = sawrni_phase77_admin_guard($request)) return $guard;
        sawrni_phase77_review_tables_ready();
        return response()->json([
            'status' => 'ok',
            'module' => 'reviews',
            'rows' => DB::table('sawrni_reviews')->orderByDesc('id')->limit(100)->get(),
            'phase' => '7.7',
        ]);
    });

    Route::get('/{id}/view', function (Request $request, int $id) {
        if ($guard = sawrni_phase77_admin_guard($request)) return $guard;
        sawrni_phase77_review_tables_ready();
        $review = DB::table('sawrni_reviews')->where('id', $id)->first();
        if (!$review) {
            return response()->json(['status' => 'error', 'message_en' => 'Review not found.', 'phase' => '7.7'], 404);
        }
        return response()->json(['status' => 'ok', 'row' => $review, 'phase' => '7.7']);
    });

    Route::post('/{id}/approve', function (Request $request, int $id) {
        if ($guard = sawrni_phase77_admin_guard($request)) return $guard;
        sawrni_phase77_review_tables_ready();
        $review = DB::table('sawrni_reviews')->where('id', $id)->first();
        if (!$review) {
            return response()->json(['status' => 'error', 'message_en' => 'Review not found.', 'phase' => '7.7'], 404);
        }

        DB::table('sawrni_reviews')->where('id', $id)->update([
            'status' => 'approved',
            'approved_by' => $request->input('admin_id', 1),
            'approved_at' => now(),
            'rejected_at' => null,
            'admin_note' => $request->input('note'),
            'updated_at' => now(),
        ]);

        sawrni_phase77_audit_review($request, $id, 'review_approved_for_public_publish', [
            'actor_id' => $request->input('admin_id', 1),
            'actor_role' => 'super_admin_or_coo',
            'note' => $request->input('note'),
        ]);

        return response()->json([
            'status' => 'ok',
            'item_status' => 'approved',
            'message_ar' => 'تمت الموافقة على التقييم ونشره.',
            'message_en' => 'Review approved and published.',
            'phase' => '7.7',
        ]);
    });

    Route::post('/{id}/reject', function (Request $request, int $id) {
        if ($guard = sawrni_phase77_admin_guard($request)) return $guard;
        sawrni_phase77_review_tables_ready();
        $review = DB::table('sawrni_reviews')->where('id', $id)->first();
        if (!$review) {
            return response()->json(['status' => 'error', 'message_en' => 'Review not found.', 'phase' => '7.7'], 404);
        }

        DB::table('sawrni_reviews')->where('id', $id)->update([
            'status' => 'rejected',
            'rejected_at' => now(),
            'admin_note' => $request->input('reason'),
            'updated_at' => now(),
        ]);

        sawrni_phase77_audit_review($request, $id, 'review_rejected_before_public_publish', [
            'actor_id' => $request->input('admin_id', 1),
            'actor_role' => 'super_admin_or_coo',
            'reason' => $request->input('reason'),
        ]);

        return response()->json([
            'status' => 'ok',
            'item_status' => 'rejected',
            'message_ar' => 'تم رفض التقييم ولن يظهر للعامة.',
            'message_en' => 'Review rejected and will not be public.',
            'phase' => '7.7',
        ]);
    });
});
