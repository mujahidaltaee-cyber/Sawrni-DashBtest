<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;

function sawrni76_now() {
    return now();
}

function sawrni76_bearer(Request $request): ?string {
    $header = $request->header('Authorization', '');
    if (preg_match('/Bearer\s+(.+)/i', $header, $m)) {
        return trim($m[1]);
    }
    return null;
}

function sawrni76_session(Request $request): array {
    $token = sawrni76_bearer($request);
    if (!$token) {
        abort(response()->json([
            'status' => 'error',
            'message_ar' => 'تسجيل الدخول مطلوب.',
            'message_en' => 'Authentication is required.',
        ], 401));
    }

    $hash = hash('sha256', $token);
    $session = null;

    if (\Illuminate\Support\Facades\Schema::hasTable('sawrni_app_sessions')) {
        $session = DB::table('sawrni_app_sessions')
            ->where(function ($q) use ($token, $hash) {
                $q->where('token', $token)->orWhere('token_hash', $hash);
            })
            ->whereNull('revoked_at')
            ->first();
    }

    if (!$session && \Illuminate\Support\Facades\Schema::hasTable('admin_auth_sessions')) {
        $session = DB::table('admin_auth_sessions')
            ->where(function ($q) use ($token, $hash) {
                $q->where('token', $token)->orWhere('token_hash', $hash);
            })
            ->whereNull('revoked_at')
            ->first();
    }

    if (!$session) {
        abort(response()->json([
            'status' => 'error',
            'message_ar' => 'جلسة الدخول غير صالحة.',
            'message_en' => 'Invalid session.',
        ], 401));
    }

    $role = $session->role ?? $session->mode ?? 'user';
    return [
        'id' => (int)($session->user_id ?? 0),
        'phone' => $session->phone ?? null,
        'role' => $role,
    ];
}

function sawrni76_audit(string $event, array $actor, string $subjectType, int $subjectId, array $payload = []): void {
    if (!\Illuminate\Support\Facades\Schema::hasTable('sawrni_delivery_audit_logs')) return;

    DB::table('sawrni_delivery_audit_logs')->insert([
        'actor_role' => $actor['role'] ?? null,
        'actor_id' => $actor['id'] ?? null,
        'event' => $event,
        'subject_type' => $subjectType,
        'subject_id' => $subjectId,
        'payload' => json_encode($payload, JSON_UNESCAPED_UNICODE),
        'created_at' => sawrni76_now(),
    ]);
}

function sawrni76_log_access(Request $request, ?int $deliveryId, string $action, array $actor = [], array $meta = []): void {
    if (!\Illuminate\Support\Facades\Schema::hasTable('sawrni_delivery_access_logs')) return;

    DB::table('sawrni_delivery_access_logs')->insert([
        'delivery_upload_id' => $deliveryId,
        'actor_role' => $actor['role'] ?? null,
        'actor_id' => $actor['id'] ?? null,
        'action' => $action,
        'ip_address' => $request->ip(),
        'user_agent' => $request->userAgent(),
        'meta' => json_encode($meta, JSON_UNESCAPED_UNICODE),
        'created_at' => sawrni76_now(),
    ]);
}

function sawrni76_require_role(array $actor, array $allowed): void {
    $role = $actor['role'] ?? '';
    if (!in_array($role, $allowed, true)) {
        abort(response()->json([
            'status' => 'error',
            'message_ar' => 'لا تملك صلاحية تنفيذ هذا الإجراء.',
            'message_en' => 'You are not allowed to perform this action.',
        ], 403));
    }
}

Route::prefix('/v1/mobile/delivery')->group(function () {
    Route::post('/provider/bookings/{booking}/upload', function (Request $request, int $booking) {
        $actor = sawrni76_session($request);
        sawrni76_require_role($actor, ['provider', 'super_admin', 'admin', 'local_test']);

        $data = $request->validate([
            'title' => ['nullable', 'string', 'max:180'],
            'notes' => ['nullable', 'string', 'max:5000'],
            'customer_id' => ['nullable', 'integer'],
            'file' => ['nullable', 'file', 'max:512000'],
        ]);

        $path = null;
        $original = null;
        $mime = null;
        $size = null;

        if ($request->hasFile('file')) {
            $file = $request->file('file');
            $original = $file->getClientOriginalName();
            $mime = $file->getMimeType();
            $size = $file->getSize();
            $path = $file->store('sawrni/private/deliveries');
        } else {
            $original = 'delivery-placeholder.txt';
            $mime = 'text/plain';
            $content = "Sawrni delivery placeholder for booking #{$booking}\nUploaded at: " . sawrni76_now()->toIso8601String() . "\n";
            $path = 'sawrni/private/deliveries/booking-' . $booking . '-' . bin2hex(random_bytes(6)) . '.txt';
            Storage::put($path, $content);
            $size = strlen($content);
        }

        $id = DB::table('sawrni_delivery_uploads')->insertGetId([
            'booking_id' => $booking,
            'provider_id' => $actor['id'] ?: null,
            'customer_id' => $data['customer_id'] ?? null,
            'title' => $data['title'] ?? 'ملفات التسليم',
            'notes' => $data['notes'] ?? null,
            'status' => 'pending_admin_review',
            'storage_disk' => 'local_private',
            'file_path' => $path,
            'original_filename' => $original,
            'mime_type' => $mime,
            'file_size_bytes' => $size,
            'provider_submitted_at' => sawrni76_now(),
            'created_at' => sawrni76_now(),
            'updated_at' => sawrni76_now(),
        ]);

        sawrni76_audit('provider_delivery_uploaded', $actor, 'delivery_upload', $id, [
            'booking_id' => $booking,
            'file' => $original,
            'status' => 'pending_admin_review',
        ]);

        return response()->json([
            'status' => 'ok',
            'message_ar' => 'تم رفع ملفات التسليم وهي بانتظار مراجعة الإدارة.',
            'message_en' => 'Delivery files uploaded and pending admin review.',
            'delivery_id' => $id,
            'delivery_status' => 'pending_admin_review',
            'phase' => '7.6',
        ]);
    });

    Route::get('/customer/bookings/{booking}/deliveries', function (Request $request, int $booking) {
        $actor = sawrni76_session($request);
        sawrni76_require_role($actor, ['customer', 'super_admin', 'admin', 'local_test']);

        $rows = DB::table('sawrni_delivery_uploads')
            ->where('booking_id', $booking)
            ->whereIn('status', ['approved', 'customer_access_granted'])
            ->orderByDesc('id')
            ->get()
            ->map(fn ($row) => [
                'id' => $row->id,
                'booking_id' => $row->booking_id,
                'title' => $row->title,
                'notes' => $row->notes,
                'status' => $row->status,
                'original_filename' => $row->original_filename,
                'mime_type' => $row->mime_type,
                'file_size_bytes' => $row->file_size_bytes,
                'created_at' => $row->created_at,
            ]);

        return response()->json([
            'status' => 'ok',
            'phase' => '7.6',
            'rows' => $rows,
        ]);
    });

    Route::post('/customer/deliveries/{delivery}/signed-access', function (Request $request, int $delivery) {
        $actor = sawrni76_session($request);
        sawrni76_require_role($actor, ['customer', 'super_admin', 'admin', 'local_test']);

        $row = DB::table('sawrni_delivery_uploads')->where('id', $delivery)->first();
        if (!$row || !in_array($row->status, ['approved', 'customer_access_granted'], true)) {
            return response()->json([
                'status' => 'error',
                'message_ar' => 'ملف التسليم غير متاح بعد.',
                'message_en' => 'Delivery file is not available yet.',
            ], 404);
        }

        $token = 'sawrni-dlv-' . bin2hex(random_bytes(32));
        $expires = sawrni76_now()->addMinutes(30);

        DB::table('sawrni_delivery_uploads')->where('id', $delivery)->update([
            'latest_access_token_hash' => hash('sha256', $token),
            'latest_access_expires_at' => $expires,
            'status' => 'customer_access_granted',
            'updated_at' => sawrni76_now(),
        ]);

        sawrni76_log_access($request, $delivery, 'signed_access_created', $actor, ['expires_at' => $expires->toIso8601String()]);

        return response()->json([
            'status' => 'ok',
            'message_ar' => 'تم إنشاء رابط وصول مؤقت.',
            'message_en' => 'Temporary signed access created.',
            'access_token' => $token,
            'expires_at' => $expires->toIso8601String(),
            'meta_url' => '/api/v1/delivery-access/' . $token . '/meta',
            'download_url' => '/api/v1/delivery-access/' . $token . '/download',
            'phase' => '7.6',
        ]);
    });
});

Route::prefix('/v1/admin-v10/delivery')->group(function () {
    Route::get('/', function (Request $request) {
        $actor = sawrni76_session($request);
        sawrni76_require_role($actor, ['super_admin', 'admin', 'coo', 'local_test']);

        $rows = DB::table('sawrni_delivery_uploads')->orderByDesc('id')->limit(100)->get();
        return response()->json(['status' => 'ok', 'phase' => '7.6', 'rows' => $rows]);
    });

    Route::post('/{delivery}/approve', function (Request $request, int $delivery) {
        $actor = sawrni76_session($request);
        sawrni76_require_role($actor, ['super_admin', 'admin', 'coo', 'local_test']);

        $updated = DB::table('sawrni_delivery_uploads')->where('id', $delivery)->update([
            'status' => 'approved',
            'admin_reviewed_at' => sawrni76_now(),
            'admin_id' => $actor['id'] ?: null,
            'admin_notes' => $request->input('notes'),
            'updated_at' => sawrni76_now(),
        ]);

        if (!$updated) {
            return response()->json(['status' => 'error', 'message_en' => 'Delivery not found.'], 404);
        }

        sawrni76_audit('admin_delivery_approved', $actor, 'delivery_upload', $delivery);
        return response()->json([
            'status' => 'ok',
            'message_ar' => 'تمت الموافقة على ملفات التسليم.',
            'message_en' => 'Delivery files approved.',
            'item_status' => 'approved',
            'phase' => '7.6',
        ]);
    });

    Route::post('/{delivery}/reject', function (Request $request, int $delivery) {
        $actor = sawrni76_session($request);
        sawrni76_require_role($actor, ['super_admin', 'admin', 'coo', 'local_test']);

        $request->validate(['reason' => ['required', 'string', 'max:2000']]);
        $updated = DB::table('sawrni_delivery_uploads')->where('id', $delivery)->update([
            'status' => 'rejected',
            'admin_reviewed_at' => sawrni76_now(),
            'admin_id' => $actor['id'] ?: null,
            'admin_notes' => $request->input('reason'),
            'updated_at' => sawrni76_now(),
        ]);

        if (!$updated) {
            return response()->json(['status' => 'error', 'message_en' => 'Delivery not found.'], 404);
        }

        sawrni76_audit('admin_delivery_rejected', $actor, 'delivery_upload', $delivery, ['reason' => $request->input('reason')]);
        return response()->json([
            'status' => 'ok',
            'message_ar' => 'تم رفض ملفات التسليم مع تسجيل السبب.',
            'message_en' => 'Delivery files rejected with reason.',
            'item_status' => 'rejected',
            'phase' => '7.6',
        ]);
    });
});

Route::prefix('/v1/delivery-access')->group(function () {
    Route::get('/{token}/meta', function (Request $request, string $token) {
        $hash = hash('sha256', $token);
        $row = DB::table('sawrni_delivery_uploads')
            ->where('latest_access_token_hash', $hash)
            ->where('latest_access_expires_at', '>', sawrni76_now())
            ->first();

        if (!$row) {
            return response()->json([
                'status' => 'error',
                'message_ar' => 'رابط الوصول منتهي أو غير صالح.',
                'message_en' => 'Signed access link is expired or invalid.',
            ], 404);
        }

        sawrni76_log_access($request, $row->id, 'signed_meta_viewed');
        return response()->json([
            'status' => 'ok',
            'delivery' => [
                'id' => $row->id,
                'booking_id' => $row->booking_id,
                'title' => $row->title,
                'notes' => $row->notes,
                'original_filename' => $row->original_filename,
                'mime_type' => $row->mime_type,
                'file_size_bytes' => $row->file_size_bytes,
                'expires_at' => $row->latest_access_expires_at,
            ],
            'phase' => '7.6',
        ]);
    });

    Route::get('/{token}/download', function (Request $request, string $token) {
        $hash = hash('sha256', $token);
        $row = DB::table('sawrni_delivery_uploads')
            ->where('latest_access_token_hash', $hash)
            ->where('latest_access_expires_at', '>', sawrni76_now())
            ->first();

        if (!$row || !$row->file_path || !Storage::exists($row->file_path)) {
            return response()->json([
                'status' => 'error',
                'message_ar' => 'الملف غير متاح أو الرابط منتهي.',
                'message_en' => 'File is unavailable or signed access expired.',
            ], 404);
        }

        sawrni76_log_access($request, $row->id, 'signed_file_downloaded');
        return Storage::download($row->file_path, $row->original_filename ?: ('sawrni-delivery-' . $row->id));
    });
});
