<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Str;

function sawrni_p73_tables_ready(): void
{
    if (!Schema::hasTable('sawrni_phase7_service_categories')) {
        Schema::create('sawrni_phase7_service_categories', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique();
            $table->string('name_ar');
            $table->string('name_en')->nullable();
            $table->text('description_ar')->nullable();
            $table->text('description_en')->nullable();
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });
    }
    if (!Schema::hasTable('sawrni_phase7_provider_profiles')) {
        Schema::create('sawrni_phase7_provider_profiles', function (Blueprint $table) {
            $table->id();
            $table->string('display_name');
            $table->string('provider_type')->default('photographer');
            $table->string('service_type')->default('photography');
            $table->string('city')->default('Baghdad');
            $table->string('subscription_plan')->nullable();
            $table->string('approval_status')->default('pending');
            $table->unsignedBigInteger('debt_balance_iqd')->default(0);
            $table->boolean('is_suspended')->default(false);
            $table->decimal('rating', 3, 2)->nullable();
            $table->string('phone')->nullable();
            $table->unsignedInteger('starting_price_iqd')->nullable();
            $table->text('bio_ar')->nullable();
            $table->text('bio_en')->nullable();
            $table->timestamp('approved_at')->nullable();
            $table->timestamps();
        });
    }
    if (!Schema::hasTable('sawrni_phase7_booking_requests')) {
        Schema::create('sawrni_phase7_booking_requests', function (Blueprint $table) {
            $table->id();
            $table->string('booking_code')->unique();
            $table->unsignedBigInteger('customer_id')->nullable();
            $table->string('customer_phone')->nullable();
            $table->string('customer_name')->nullable();
            $table->unsignedBigInteger('provider_id');
            $table->string('provider_name')->nullable();
            $table->string('service_type')->default('photography');
            $table->string('city')->nullable();
            $table->string('location_text')->nullable();
            $table->timestamp('scheduled_at')->nullable();
            $table->unsignedInteger('total_amount_iqd')->default(0);
            $table->unsignedInteger('deposit_amount_iqd')->default(0);
            $table->unsignedInteger('final_price_iqd')->default(0);
            $table->unsignedInteger('platform_commission_iqd')->default(0);
            $table->string('payment_status')->default('deposit_pending');
            $table->string('status')->default('pending_provider_confirmation');
            $table->timestamp('customer_edit_deadline_at')->nullable();
            $table->timestamp('deposit_refundable_until')->nullable();
            $table->text('customer_notes')->nullable();
            $table->timestamps();
        });
    }
}

function sawrni_p73_session(Request $request): ?object
{
    $auth = $request->header('Authorization', '');
    $token = trim(str_replace('Bearer ', '', $auth));
    if ($token === '') return null;

    $hash = hash('sha256', $token);
    foreach (['sawrni_app_sessions', 'admin_auth_sessions'] as $table) {
        if (!Schema::hasTable($table)) continue;
        $query = DB::table($table);
        if (Schema::hasColumn($table, 'token_hash')) $query->where('token_hash', $hash);
        elseif (Schema::hasColumn($table, 'token')) $query->where('token', $token);
        else continue;
        $row = $query->first();
        if ($row) return $row;
    }
    return null;
}

function sawrni_p73_provider_query()
{
    return DB::table('sawrni_phase7_provider_profiles')
        ->where('approval_status', 'approved')
        ->where('is_suspended', false)
        ->where(function ($q) {
            $q->whereNull('debt_balance_iqd')->orWhere('debt_balance_iqd', '<', 75000);
        });
}

Route::prefix('/v1/mobile/customer')->group(function () {
    Route::get('/categories', function () {
        sawrni_p73_tables_ready();
        return response()->json([
            'status' => 'ok',
            'phase' => '7.3',
            'rows' => DB::table('sawrni_phase7_service_categories')
                ->where('is_active', true)
                ->orderBy('sort_order')
                ->get(),
        ]);
    });

    Route::get('/providers', function (Request $request) {
        sawrni_p73_tables_ready();
        $q = sawrni_p73_provider_query();

        if ($request->filled('service_type')) $q->where('service_type', $request->query('service_type'));
        if ($request->filled('city')) $q->where('city', $request->query('city'));
        if ($request->filled('q')) {
            $term = '%' . $request->query('q') . '%';
            $q->where(function ($inner) use ($term) {
                $inner->where('display_name', 'like', $term)
                    ->orWhere('bio_ar', 'like', $term)
                    ->orWhere('bio_en', 'like', $term);
            });
        }

        return response()->json([
            'status' => 'ok',
            'phase' => '7.3',
            'rows' => $q->orderByDesc('subscription_plan')->orderByDesc('rating')->get(),
            'rules' => [
                'visibility' => 'Only COO/admin approved providers are returned to customers.',
                'debt_threshold_iqd' => 75000,
            ],
        ]);
    });

    Route::get('/providers/{id}', function (int $id) {
        sawrni_p73_tables_ready();
        $provider = sawrni_p73_provider_query()->where('id', $id)->first();
        if (!$provider) {
            return response()->json(['status' => 'error', 'message_en' => 'Provider not available.', 'message_ar' => 'مزود الخدمة غير متاح.'], 404);
        }
        return response()->json(['status' => 'ok', 'phase' => '7.3', 'row' => $provider]);
    });

    Route::get('/bookings', function (Request $request) {
        sawrni_p73_tables_ready();
        $session = sawrni_p73_session($request);
        if (!$session) return response()->json(['status' => 'error', 'message_en' => 'Authentication required.', 'message_ar' => 'يجب تسجيل الدخول.'], 401);

        $phone = $session->phone ?? null;
        $rows = DB::table('sawrni_phase7_booking_requests')
            ->when($phone, fn($q) => $q->where('customer_phone', $phone))
            ->orderByDesc('id')
            ->get();

        return response()->json(['status' => 'ok', 'phase' => '7.3', 'rows' => $rows]);
    });

    Route::post('/bookings', function (Request $request) {
        sawrni_p73_tables_ready();
        $session = sawrni_p73_session($request);
        if (!$session) return response()->json(['status' => 'error', 'message_en' => 'Authentication required.', 'message_ar' => 'يجب تسجيل الدخول.'], 401);

        $providerId = (int) $request->input('provider_id');
        $provider = sawrni_p73_provider_query()->where('id', $providerId)->first();
        if (!$provider) return response()->json(['status' => 'error', 'message_en' => 'Provider not available.', 'message_ar' => 'مزود الخدمة غير متاح.'], 404);

        $total = max(0, (int) $request->input('total_amount_iqd', $provider->starting_price_iqd ?? 0));
        if ($total < 10000) {
            return response()->json(['status' => 'error', 'message_en' => 'Booking amount is too low.', 'message_ar' => 'مبلغ الحجز غير صالح.'], 422);
        }

        $deposit = (int) $request->input('deposit_amount_iqd', (int) ceil($total * 0.30));
        $deposit = min($total, max(0, $deposit));
        $final = max(0, $total - $deposit);
        $commission = (int) round($total * 0.15);
        $now = now();

        $id = DB::table('sawrni_phase7_booking_requests')->insertGetId([
            'booking_code' => 'SWR-' . strtoupper(Str::random(6)),
            'customer_id' => $session->user_id ?? null,
            'customer_phone' => $session->phone ?? $request->input('customer_phone'),
            'customer_name' => $request->input('customer_name', 'Customer'),
            'provider_id' => $provider->id,
            'provider_name' => $provider->display_name,
            'service_type' => $provider->service_type,
            'city' => $request->input('city', $provider->city),
            'location_text' => $request->input('location_text'),
            'scheduled_at' => $request->input('scheduled_at'),
            'total_amount_iqd' => $total,
            'deposit_amount_iqd' => $deposit,
            'final_price_iqd' => $final,
            'platform_commission_iqd' => $commission,
            'payment_status' => 'deposit_pending',
            'status' => 'pending_provider_confirmation',
            'customer_edit_deadline_at' => $now->copy()->addHours(3),
            'deposit_refundable_until' => $now->copy()->addHour(),
            'customer_notes' => $request->input('customer_notes'),
            'created_at' => $now,
            'updated_at' => $now,
        ]);

        return response()->json([
            'status' => 'ok',
            'phase' => '7.3',
            'message_ar' => 'تم إنشاء طلب الحجز بانتظار دفع العربون وتأكيد مزود الخدمة.',
            'message_en' => 'Booking request created and is waiting for deposit payment and provider confirmation.',
            'row' => DB::table('sawrni_phase7_booking_requests')->where('id', $id)->first(),
            'business_rules' => [
                'commission_rate' => '15%',
                'customer_edit_window_after_deposit_hours' => 3,
                'deposit_refund_window_after_deposit_hours' => 1,
            ],
        ]);
    });
});

Route::get('/v1/mobile/marketplace/summary', function () {
    sawrni_p73_tables_ready();
    return response()->json([
        'status' => 'ok',
        'phase' => '7.3',
        'approved_providers' => sawrni_p73_provider_query()->count(),
        'pending_provider_profiles_hidden' => DB::table('sawrni_phase7_provider_profiles')->where('approval_status', 'pending')->count(),
        'booking_requests' => DB::table('sawrni_phase7_booking_requests')->count(),
        'commission_rate' => 0.15,
        'slogan_ar' => 'استوديو كامل بجيبك',
    ]);
});
