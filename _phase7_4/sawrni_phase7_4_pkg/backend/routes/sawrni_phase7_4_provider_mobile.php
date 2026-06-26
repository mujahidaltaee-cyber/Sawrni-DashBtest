<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Schema;

function sawrni74_provider_id_from_request(Request $request): int
{
    $auth = $request->header('Authorization', '');
    $token = trim(str_replace('Bearer', '', $auth));

    if ($token !== '' && Schema::hasTable('app_sessions')) {
        $session = DB::table('app_sessions')->where('token_hash', hash('sha256', $token))->first();
        if ($session && !empty($session->user_id)) {
            return (int) $session->user_id;
        }
    }

    if ($token !== '' && Schema::hasTable('admin_auth_sessions')) {
        $session = DB::table('admin_auth_sessions')
            ->where(function ($query) use ($token) {
                $query->where('token', $token)->orWhere('token_hash', hash('sha256', $token));
            })
            ->first();

        if ($session && !empty($session->user_id)) {
            return (int) $session->user_id;
        }
    }

    return 1;
}

function sawrni74_mask_phone(?string $phone): string
{
    $phone = $phone ?: '';
    if (strlen($phone) < 5) return '07*********';
    return substr($phone, 0, 3) . '******' . substr($phone, -2);
}

function sawrni74_booking_row($row): array
{
    $row = (array) $row;
    $phone = $row['customer_phone'] ?? null;
    $row['masked_phone'] = $row['masked_phone'] ?? sawrni74_mask_phone($phone);
    unset($row['customer_phone']);
    return $row;
}

Route::prefix('/v1/mobile/provider')->group(function () {
    Route::get('/bookings', function (Request $request) {
        if (!Schema::hasTable('sawrni_phase7_booking_requests')) {
            return response()->json([
                'status' => 'ok',
                'rows' => [],
                'source' => 'phase7_4_provider_dashboard',
            ]);
        }

        $providerId = sawrni74_provider_id_from_request($request);

        $rows = DB::table('sawrni_phase7_booking_requests')
            ->where(function ($query) use ($providerId) {
                $query->where('provider_id', $providerId)->orWhereNull('provider_id');
            })
            ->orderByDesc('id')
            ->limit(50)
            ->get()
            ->map(fn ($row) => sawrni74_booking_row($row))
            ->values();

        return response()->json([
            'status' => 'ok',
            'rows' => $rows,
            'source' => 'phase7_4_provider_dashboard',
        ]);
    });

    Route::get('/bookings/{id}', function (Request $request, int $id) {
        if (!Schema::hasTable('sawrni_phase7_booking_requests')) {
            return response()->json(['status' => 'error', 'message_en' => 'Booking table is not ready.'], 404);
        }

        $providerId = sawrni74_provider_id_from_request($request);

        $row = DB::table('sawrni_phase7_booking_requests')
            ->where('id', $id)
            ->where(function ($query) use ($providerId) {
                $query->where('provider_id', $providerId)->orWhereNull('provider_id');
            })
            ->first();

        if (!$row) {
            return response()->json(['status' => 'error', 'message_en' => 'Booking not found.'], 404);
        }

        return response()->json([
            'status' => 'ok',
            'row' => sawrni74_booking_row($row),
        ]);
    });

    Route::post('/bookings/{id}/accept', function (Request $request, int $id) {
        if (!Schema::hasTable('sawrni_phase7_booking_requests')) {
            return response()->json(['status' => 'error', 'message_en' => 'Booking table is not ready.'], 404);
        }

        $providerId = sawrni74_provider_id_from_request($request);

        $updated = DB::table('sawrni_phase7_booking_requests')
            ->where('id', $id)
            ->where(function ($query) use ($providerId) {
                $query->where('provider_id', $providerId)->orWhereNull('provider_id');
            })
            ->update([
                'provider_id' => $providerId,
                'status' => 'provider_accepted',
                'provider_responded_at' => now(),
                'updated_at' => now(),
            ]);

        if (!$updated) {
            return response()->json(['status' => 'error', 'message_en' => 'Booking not found.'], 404);
        }

        if (Schema::hasTable('sawrni_phase7_booking_audit_logs')) {
            DB::table('sawrni_phase7_booking_audit_logs')->insert([
                'booking_id' => $id,
                'actor_type' => 'provider',
                'actor_id' => $providerId,
                'action' => 'provider_accepted_booking',
                'metadata' => json_encode(['ip' => $request->ip()]),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        return response()->json([
            'status' => 'ok',
            'item_status' => 'provider_accepted',
            'message_ar' => 'تم قبول الحجز.',
            'message_en' => 'Booking accepted.',
        ]);
    });

    Route::post('/bookings/{id}/reject', function (Request $request, int $id) {
        if (!Schema::hasTable('sawrni_phase7_booking_requests')) {
            return response()->json(['status' => 'error', 'message_en' => 'Booking table is not ready.'], 404);
        }

        $providerId = sawrni74_provider_id_from_request($request);
        $reason = trim((string) $request->input('reason', ''));

        $updated = DB::table('sawrni_phase7_booking_requests')
            ->where('id', $id)
            ->where(function ($query) use ($providerId) {
                $query->where('provider_id', $providerId)->orWhereNull('provider_id');
            })
            ->update([
                'provider_id' => $providerId,
                'status' => 'provider_rejected',
                'provider_rejection_reason' => $reason,
                'provider_responded_at' => now(),
                'updated_at' => now(),
            ]);

        if (!$updated) {
            return response()->json(['status' => 'error', 'message_en' => 'Booking not found.'], 404);
        }

        if (Schema::hasTable('sawrni_phase7_booking_audit_logs')) {
            DB::table('sawrni_phase7_booking_audit_logs')->insert([
                'booking_id' => $id,
                'actor_type' => 'provider',
                'actor_id' => $providerId,
                'action' => 'provider_rejected_booking',
                'metadata' => json_encode(['reason' => $reason, 'ip' => $request->ip()]),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        return response()->json([
            'status' => 'ok',
            'item_status' => 'provider_rejected',
            'message_ar' => 'تم رفض الحجز.',
            'message_en' => 'Booking rejected.',
        ]);
    });
});
