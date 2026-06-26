<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

if (!function_exists('sawrni_71_json_error')) {
    function sawrni_71_json_error(string $messageAr, string $messageEn, int $status = 400, array $extra = []) {
        return response()->json(array_merge([
            'status' => 'error',
            'message_ar' => $messageAr,
            'message_en' => $messageEn,
            'phase' => '7.1',
        ], $extra), $status);
    }
}

if (!function_exists('sawrni_71_audit')) {
    function sawrni_71_audit(Request $request, string $event, ?string $phone = null, ?string $actorType = null, array $payload = []): void {
        if (!Schema::hasTable('sawrni_mobile_audit_events')) return;
        DB::table('sawrni_mobile_audit_events')->insert([
            'actor_type' => $actorType,
            'actor_phone' => $phone,
            'event' => $event,
            'ip_address' => $request->ip(),
            'user_agent' => (string) $request->userAgent(),
            'payload' => json_encode($payload, JSON_UNESCAPED_UNICODE),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}

if (!function_exists('sawrni_71_mobile_auth')) {
    function sawrni_71_mobile_auth(Request $request): ?object {
        $header = (string) $request->header('Authorization', '');
        if (!Str::startsWith($header, 'Bearer ')) return null;
        $token = trim(Str::after($header, 'Bearer '));
        if ($token === '') return null;
        if (!Schema::hasTable('sawrni_mobile_sessions')) return null;
        return DB::table('sawrni_mobile_sessions')
            ->where('token_hash', hash('sha256', $token))
            ->whereNull('revoked_at')
            ->where(function ($query) {
                $query->whereNull('expires_at')->orWhere('expires_at', '>', now());
            })
            ->first();
    }
}

if (!function_exists('sawrni_71_provider_profile_for_phone')) {
    function sawrni_71_provider_profile_for_phone(?string $phone): ?object {
        if (!$phone || !Schema::hasTable('sawrni_provider_profiles_secure')) return null;
        return DB::table('sawrni_provider_profiles_secure')->where('phone', $phone)->orderByDesc('id')->first();
    }
}

Route::prefix('/v1/mobile')->group(function () {
    Route::get('/health', function () {
        return response()->json([
            'status' => 'ok',
            'app' => 'Sawrni',
            'phase' => '7.1',
            'mobile' => 'flutter-foundation',
            'backend' => 'laravel-api',
            'database' => 'ok',
        ]);
    });

    Route::post('/auth/request-otp', function (Request $request) {
        $data = $request->validate([
            'phone' => ['required', 'string', 'min:8', 'max:24'],
            'role' => ['required', 'string', 'in:customer,provider'],
            'purpose' => ['nullable', 'string', 'max:32'],
        ]);

        $phone = preg_replace('/\s+/', '', $data['phone']);
        $role = $data['role'];
        $purpose = $data['purpose'] ?? 'login';
        $otp = app()->environment('production') ? (string) random_int(100000, 999999) : '123456';

        if (!Schema::hasTable('sawrni_mobile_otps')) {
            return sawrni_71_json_error('جداول التطبيق غير جاهزة.', 'Mobile tables are not ready.', 500);
        }

        DB::table('sawrni_mobile_otps')->where('phone', $phone)->where('role', $role)->where('status', 'pending')->update([
            'status' => 'replaced',
            'updated_at' => now(),
        ]);

        DB::table('sawrni_mobile_otps')->insert([
            'phone' => $phone,
            'role' => $role,
            'purpose' => $purpose,
            'otp_hash' => Hash::make($otp),
            'status' => 'pending',
            'attempts' => 0,
            'expires_at' => now()->addMinutes(5),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        sawrni_71_audit($request, 'mobile_otp_requested', $phone, $role, ['purpose' => $purpose]);

        $response = [
            'status' => 'ok',
            'message_ar' => 'تم إرسال رمز التحقق.',
            'message_en' => 'OTP has been sent.',
            'role' => $role,
            'phase' => '7.1',
        ];

        if (!app()->environment('production')) {
            $response['dev_otp'] = $otp;
        }

        return response()->json($response);
    });

    Route::post('/auth/verify-otp', function (Request $request) {
        $data = $request->validate([
            'phone' => ['required', 'string', 'min:8', 'max:24'],
            'role' => ['required', 'string', 'in:customer,provider'],
            'otp' => ['required', 'string', 'min:4', 'max:8'],
            'device_name' => ['nullable', 'string', 'max:120'],
        ]);

        $phone = preg_replace('/\s+/', '', $data['phone']);
        $role = $data['role'];

        $record = DB::table('sawrni_mobile_otps')
            ->where('phone', $phone)
            ->where('role', $role)
            ->where('status', 'pending')
            ->where('expires_at', '>', now())
            ->orderByDesc('id')
            ->first();

        if (!$record) {
            sawrni_71_audit($request, 'mobile_otp_missing_or_expired', $phone, $role);
            return sawrni_71_json_error('رمز التحقق غير صالح أو منتهي.', 'OTP is invalid or expired.', 422);
        }

        if ($record->attempts >= 5 || !Hash::check($data['otp'], $record->otp_hash)) {
            DB::table('sawrni_mobile_otps')->where('id', $record->id)->increment('attempts');
            sawrni_71_audit($request, 'mobile_otp_failed', $phone, $role);
            return sawrni_71_json_error('رمز التحقق غير صحيح.', 'OTP is incorrect.', 422);
        }

        DB::table('sawrni_mobile_otps')->where('id', $record->id)->update([
            'status' => 'consumed',
            'consumed_at' => now(),
            'updated_at' => now(),
        ]);

        $token = 'sawrni-app-' . bin2hex(random_bytes(32));

        DB::table('sawrni_mobile_sessions')->insert([
            'user_id' => null,
            'phone' => $phone,
            'role' => $role,
            'token_hash' => hash('sha256', $token),
            'device_name' => $data['device_name'] ?? 'mobile-app',
            'expires_at' => now()->addDays(30),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $providerProfile = $role === 'provider' ? sawrni_71_provider_profile_for_phone($phone) : null;
        $approvalStatus = $providerProfile->approval_status ?? ($role === 'provider' ? 'pending' : null);

        sawrni_71_audit($request, 'mobile_login_success', $phone, $role);

        return response()->json([
            'status' => 'ok',
            'token' => $token,
            'user' => [
                'phone' => $phone,
                'role' => $role,
                'provider_approval_status' => $approvalStatus,
            ],
            'phase' => '7.1',
        ]);
    });

    Route::post('/auth/logout', function (Request $request) {
        $session = sawrni_71_mobile_auth($request);
        if (!$session) return response()->json(['status' => 'ok']);
        DB::table('sawrni_mobile_sessions')->where('id', $session->id)->update([
            'revoked_at' => now(),
            'updated_at' => now(),
        ]);
        sawrni_71_audit($request, 'mobile_logout', $session->phone, $session->role);
        return response()->json(['status' => 'ok']);
    });

    Route::get('/customer/home', function (Request $request) {
        $session = sawrni_71_mobile_auth($request);
        if (!$session || $session->role !== 'customer') {
            return sawrni_71_json_error('غير مصرح.', 'Unauthorized.', 401);
        }

        $providers = [];
        if (Schema::hasTable('sawrni_provider_profiles_secure')) {
            $providers = DB::table('sawrni_provider_profiles_secure')
                ->where('approval_status', 'approved')
                ->where('is_suspended', false)
                ->select('id', 'display_name', 'provider_type', 'category', 'city', 'subscription_plan', 'rating', 'bio', 'public_portfolio_note')
                ->orderByDesc('rating')
                ->limit(12)
                ->get();
        }

        return response()->json([
            'status' => 'ok',
            'customer' => ['phone' => $session->phone],
            'categories' => [
                ['key' => 'photography', 'title_ar' => 'تصوير', 'title_en' => 'Photography'],
                ['key' => 'editing', 'title_ar' => 'تعديل صور', 'title_en' => 'Photo Editing'],
                ['key' => 'modeling', 'title_ar' => 'مودلز', 'title_en' => 'Models'],
            ],
            'featured_providers' => $providers,
            'privacy_note_en' => 'Provider contact details are hidden until booking/payment rules allow access.',
            'privacy_note_ar' => 'تُخفى معلومات التواصل الخاصة بالمزودين إلى أن تسمح قواعد الحجز والدفع بالوصول إليها.',
            'phase' => '7.1',
        ]);
    });

    Route::get('/provider/home', function (Request $request) {
        $session = sawrni_71_mobile_auth($request);
        if (!$session || $session->role !== 'provider') {
            return sawrni_71_json_error('غير مصرح.', 'Unauthorized.', 401);
        }

        $profile = sawrni_71_provider_profile_for_phone($session->phone);
        $approvalStatus = $profile->approval_status ?? 'pending';

        return response()->json([
            'status' => 'ok',
            'provider' => [
                'phone' => $session->phone,
                'display_name' => $profile->display_name ?? null,
                'provider_type' => $profile->provider_type ?? null,
                'category' => $profile->category ?? null,
                'city' => $profile->city ?? null,
                'subscription_plan' => $profile->subscription_plan ?? 'basic',
                'approval_status' => $approvalStatus,
                'is_visible_to_customers' => $approvalStatus === 'approved' && !($profile->is_suspended ?? false),
                'debt_balance_iqd' => (int) ($profile->debt_balance_iqd ?? 0),
                'debt_threshold_iqd' => 75000,
            ],
            'message_ar' => $approvalStatus === 'approved'
                ? 'حسابك ظاهر للعملاء حسب قواعد المنصة.'
                : 'حسابك غير ظاهر للعملاء إلى حين موافقة الإدارة/COO.',
            'message_en' => $approvalStatus === 'approved'
                ? 'Your profile can appear to customers according to platform rules.'
                : 'Your profile is hidden from customers until admin/COO approval.',
            'phase' => '7.1',
        ]);
    });

    Route::post('/provider/profile', function (Request $request) {
        $session = sawrni_71_mobile_auth($request);
        if (!$session || $session->role !== 'provider') {
            return sawrni_71_json_error('غير مصرح.', 'Unauthorized.', 401);
        }

        $data = $request->validate([
            'display_name' => ['required', 'string', 'max:160'],
            'provider_type' => ['required', 'string', 'in:photographer,editor,model'],
            'category' => ['required', 'string', 'max:100'],
            'city' => ['required', 'string', 'max:100'],
            'subscription_plan' => ['required', 'string', 'in:basic,standard,premium'],
            'bio' => ['nullable', 'string', 'max:2000'],
            'public_portfolio_note' => ['nullable', 'string', 'max:2000'],
        ]);

        if (!Schema::hasTable('sawrni_provider_profiles_secure')) {
            return sawrni_71_json_error('جدول المزودين غير جاهز.', 'Provider table is not ready.', 500);
        }

        $existing = DB::table('sawrni_provider_profiles_secure')->where('phone', $session->phone)->first();
        $payload = [
            'phone' => $session->phone,
            'display_name' => $data['display_name'],
            'provider_type' => $data['provider_type'],
            'category' => $data['category'],
            'city' => $data['city'],
            'subscription_plan' => $data['subscription_plan'],
            'bio' => $data['bio'] ?? null,
            'public_portfolio_note' => $data['public_portfolio_note'] ?? null,
            'approval_status' => 'pending',
            'is_suspended' => false,
            'updated_at' => now(),
        ];

        if ($existing) {
            DB::table('sawrni_provider_profiles_secure')->where('id', $existing->id)->update($payload);
            $profileId = $existing->id;
        } else {
            $payload['created_at'] = now();
            $profileId = DB::table('sawrni_provider_profiles_secure')->insertGetId($payload);
        }

        sawrni_71_audit($request, 'provider_profile_submitted', $session->phone, 'provider', ['profile_id' => $profileId]);

        return response()->json([
            'status' => 'ok',
            'message_ar' => 'تم إرسال ملف المزود للمراجعة. لن يظهر للعملاء قبل موافقة الإدارة/COO.',
            'message_en' => 'Provider profile submitted for review. It will not appear to customers before admin/COO approval.',
            'profile_id' => $profileId,
            'approval_status' => 'pending',
            'phase' => '7.1',
        ]);
    });
});
