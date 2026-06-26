<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;

function sawrni_phase75_tables_ready(): void
{
    if (!Schema::hasTable('sawrni_mobile_bookings')) {
        Schema::create('sawrni_mobile_bookings', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('customer_id')->nullable();
            $table->unsignedBigInteger('provider_id')->nullable();
            $table->string('service_type')->default('photography');
            $table->string('title_ar')->nullable();
            $table->string('title_en')->nullable();
            $table->string('provider_name')->nullable();
            $table->string('customer_phone')->nullable();
            $table->string('customer_phone_masked')->nullable();
            $table->string('location')->nullable();
            $table->timestamp('scheduled_at')->nullable();
            $table->unsignedBigInteger('total_amount_iqd')->default(0);
            $table->unsignedBigInteger('deposit_amount_iqd')->default(0);
            $table->unsignedBigInteger('final_price_iqd')->default(0);
            $table->unsignedBigInteger('platform_commission_iqd')->default(0);
            $table->unsignedInteger('commission_rate')->default(15);
            $table->string('status')->default('pending_provider');
            $table->text('provider_rejection_reason')->nullable();
            $table->timestamp('deposit_paid_at')->nullable();
            $table->timestamp('customer_edit_deadline_at')->nullable();
            $table->timestamp('deposit_refundable_until')->nullable();
            $table->timestamp('contact_revealed_at')->nullable();
            $table->timestamp('customer_cancelled_at')->nullable();
            $table->timestamps();
        });
    }

    if (!Schema::hasTable('sawrni_booking_events')) {
        Schema::create('sawrni_booking_events', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('booking_id')->nullable();
            $table->string('actor_type')->nullable();
            $table->unsignedBigInteger('actor_id')->nullable();
            $table->string('event_type');
            $table->text('details_json')->nullable();
            $table->string('ip_address')->nullable();
            $table->timestamps();
        });
    }
}

function sawrni_phase75_mask_phone(?string $phone): string
{
    $digits = preg_replace('/\D+/', '', (string)$phone);
    if (strlen($digits) <= 4) return '****';
    return substr($digits, 0, 3) . '****' . substr($digits, -2);
}

function sawrni_phase75_commission(int $amount): int
{
    return (int) round($amount * 0.15);
}

function sawrni_phase75_log_event(?int $bookingId, string $type, Request $request, array $details = []): void
{
    sawrni_phase75_tables_ready();

    DB::table('sawrni_booking_events')->insert([
        'booking_id' => $bookingId,
        'actor_type' => $details['actor_type'] ?? 'system',
        'actor_id' => $details['actor_id'] ?? null,
        'event_type' => $type,
        'details_json' => json_encode($details, JSON_UNESCAPED_UNICODE),
        'ip_address' => $request->ip(),
        'created_at' => now(),
        'updated_at' => now(),
    ]);
}

Route::prefix('/v1/mobile')->group(function () {
    Route::get('/booking-rules', function () {
        return response()->json([
            'status' => 'ok',
            'phase' => '7.5',
            'rules' => [
                'platform_commission_rate' => 15,
                'debt_threshold_iqd' => 75000,
                'customer_edit_window_hours_after_deposit' => 3,
                'customer_cancel_refund_window_hours_after_deposit' => 1,
                'deposit_after_refund_window' => 'non_refundable',
                'contact_visibility' => 'hidden_until_confirmed_booking',
                'slogan_ar' => 'استوديو كامل بجيبك',
            ],
        ]);
    });

    Route::get('/bookings', function () {
        sawrni_phase75_tables_ready();

        return response()->json([
            'status' => 'ok',
            'phase' => '7.5',
            'rows' => DB::table('sawrni_mobile_bookings')->latest('id')->limit(50)->get(),
        ]);
    });

    Route::post('/bookings', function (Request $request) {
        sawrni_phase75_tables_ready();

        $validated = $request->validate([
            'service_type' => 'nullable|string|max:80',
            'title_ar' => 'nullable|string|max:160',
            'title_en' => 'nullable|string|max:160',
            'provider_id' => 'nullable|integer',
            'provider_name' => 'nullable|string|max:160',
            'customer_phone' => 'nullable|string|max:30',
            'location' => 'nullable|string|max:160',
            'scheduled_at' => 'nullable|string|max:80',
            'total_amount_iqd' => 'required|integer|min:0',
            'deposit_amount_iqd' => 'nullable|integer|min:0',
        ]);

        $total = (int) $validated['total_amount_iqd'];
        $deposit = (int) ($validated['deposit_amount_iqd'] ?? max(10000, round($total * 0.30)));
        $commission = sawrni_phase75_commission($total);

        $id = DB::table('sawrni_mobile_bookings')->insertGetId([
            'customer_id' => $request->input('customer_id'),
            'provider_id' => $validated['provider_id'] ?? null,
            'service_type' => $validated['service_type'] ?? 'photography',
            'title_ar' => $validated['title_ar'] ?? 'حجز جديد',
            'title_en' => $validated['title_en'] ?? 'New booking',
            'provider_name' => $validated['provider_name'] ?? 'Provider',
            'customer_phone' => $validated['customer_phone'] ?? null,
            'customer_phone_masked' => sawrni_phase75_mask_phone($validated['customer_phone'] ?? ''),
            'location' => $validated['location'] ?? null,
            'scheduled_at' => $validated['scheduled_at'] ?? null,
            'total_amount_iqd' => $total,
            'deposit_amount_iqd' => $deposit,
            'final_price_iqd' => max(0, $total - $deposit),
            'platform_commission_iqd' => $commission,
            'commission_rate' => 15,
            'status' => 'pending_provider',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        sawrni_phase75_log_event($id, 'booking_created', $request, ['actor_type' => 'customer']);

        return response()->json([
            'status' => 'ok',
            'phase' => '7.5',
            'booking' => DB::table('sawrni_mobile_bookings')->where('id', $id)->first(),
        ], 201);
    });

    Route::get('/bookings/{id}', function (int $id) {
        sawrni_phase75_tables_ready();

        $booking = DB::table('sawrni_mobile_bookings')->where('id', $id)->first();
        if (!$booking) {
            return response()->json(['status' => 'error', 'message_en' => 'Booking not found.'], 404);
        }

        return response()->json(['status' => 'ok', 'phase' => '7.5', 'booking' => $booking]);
    });

    Route::post('/bookings/{id}/provider-accept', function (Request $request, int $id) {
        sawrni_phase75_tables_ready();

        $booking = DB::table('sawrni_mobile_bookings')->where('id', $id)->first();
        if (!$booking) return response()->json(['status' => 'error', 'message_en' => 'Booking not found.'], 404);
        if ($booking->status !== 'pending_provider') {
            return response()->json(['status' => 'error', 'message_en' => 'Booking is not pending provider approval.'], 422);
        }

        DB::table('sawrni_mobile_bookings')->where('id', $id)->update([
            'status' => 'accepted_waiting_deposit',
            'updated_at' => now(),
        ]);

        sawrni_phase75_log_event($id, 'provider_accepted_booking', $request, ['actor_type' => 'provider']);

        return response()->json([
            'status' => 'ok',
            'phase' => '7.5',
            'booking' => DB::table('sawrni_mobile_bookings')->where('id', $id)->first(),
        ]);
    });

    Route::post('/bookings/{id}/provider-reject', function (Request $request, int $id) {
        sawrni_phase75_tables_ready();

        $request->validate(['reason' => 'required|string|max:500']);

        $booking = DB::table('sawrni_mobile_bookings')->where('id', $id)->first();
        if (!$booking) return response()->json(['status' => 'error', 'message_en' => 'Booking not found.'], 404);
        if ($booking->status !== 'pending_provider') {
            return response()->json(['status' => 'error', 'message_en' => 'Booking is not pending provider approval.'], 422);
        }

        DB::table('sawrni_mobile_bookings')->where('id', $id)->update([
            'status' => 'rejected_by_provider',
            'provider_rejection_reason' => $request->input('reason'),
            'updated_at' => now(),
        ]);

        sawrni_phase75_log_event($id, 'provider_rejected_booking', $request, [
            'actor_type' => 'provider',
            'reason' => $request->input('reason'),
        ]);

        return response()->json([
            'status' => 'ok',
            'phase' => '7.5',
            'booking' => DB::table('sawrni_mobile_bookings')->where('id', $id)->first(),
        ]);
    });

    Route::post('/bookings/{id}/deposit-paid', function (Request $request, int $id) {
        sawrni_phase75_tables_ready();

        $booking = DB::table('sawrni_mobile_bookings')->where('id', $id)->first();
        if (!$booking) return response()->json(['status' => 'error', 'message_en' => 'Booking not found.'], 404);
        if ($booking->status !== 'accepted_waiting_deposit') {
            return response()->json(['status' => 'error', 'message_en' => 'Booking is not waiting for deposit.'], 422);
        }

        $paidAt = now();

        DB::table('sawrni_mobile_bookings')->where('id', $id)->update([
            'status' => 'confirmed',
            'deposit_paid_at' => $paidAt,
            'customer_edit_deadline_at' => $paidAt->copy()->addHours(3),
            'deposit_refundable_until' => $paidAt->copy()->addHour(),
            'contact_revealed_at' => $paidAt,
            'updated_at' => now(),
        ]);

        sawrni_phase75_log_event($id, 'deposit_paid_booking_confirmed', $request, ['actor_type' => 'customer']);

        return response()->json([
            'status' => 'ok',
            'phase' => '7.5',
            'booking' => DB::table('sawrni_mobile_bookings')->where('id', $id)->first(),
        ]);
    });

    Route::post('/bookings/{id}/customer-edit', function (Request $request, int $id) {
        sawrni_phase75_tables_ready();

        $booking = DB::table('sawrni_mobile_bookings')->where('id', $id)->first();
        if (!$booking) return response()->json(['status' => 'error', 'message_en' => 'Booking not found.'], 404);
        if ($booking->status !== 'confirmed' || !$booking->customer_edit_deadline_at || now()->greaterThan($booking->customer_edit_deadline_at)) {
            return response()->json(['status' => 'error', 'message_en' => 'Customer edit window has expired.'], 422);
        }

        $updates = [];
        foreach (['location', 'scheduled_at'] as $field) {
            if ($request->has($field)) $updates[$field] = $request->input($field);
        }
        $updates['updated_at'] = now();

        DB::table('sawrni_mobile_bookings')->where('id', $id)->update($updates);

        sawrni_phase75_log_event($id, 'customer_edited_booking', $request, [
            'actor_type' => 'customer',
            'fields' => array_keys($updates),
        ]);

        return response()->json([
            'status' => 'ok',
            'phase' => '7.5',
            'booking' => DB::table('sawrni_mobile_bookings')->where('id', $id)->first(),
        ]);
    });

    Route::post('/bookings/{id}/customer-cancel', function (Request $request, int $id) {
        sawrni_phase75_tables_ready();

        $booking = DB::table('sawrni_mobile_bookings')->where('id', $id)->first();
        if (!$booking) return response()->json(['status' => 'error', 'message_en' => 'Booking not found.'], 404);
        if (!in_array($booking->status, ['confirmed', 'accepted_waiting_deposit'], true)) {
            return response()->json(['status' => 'error', 'message_en' => 'Booking cannot be cancelled in current status.'], 422);
        }

        $refundable = $booking->deposit_refundable_until && now()->lessThanOrEqualTo($booking->deposit_refundable_until);
        $status = $refundable ? 'customer_cancelled_refundable' : 'customer_cancelled_nonrefundable';

        DB::table('sawrni_mobile_bookings')->where('id', $id)->update([
            'status' => $status,
            'customer_cancelled_at' => now(),
            'updated_at' => now(),
        ]);

        sawrni_phase75_log_event($id, 'customer_cancelled_booking', $request, [
            'actor_type' => 'customer',
            'deposit_refundable' => $refundable,
        ]);

        return response()->json([
            'status' => 'ok',
            'phase' => '7.5',
            'deposit_refundable' => $refundable,
            'booking' => DB::table('sawrni_mobile_bookings')->where('id', $id)->first(),
        ]);
    });
});
