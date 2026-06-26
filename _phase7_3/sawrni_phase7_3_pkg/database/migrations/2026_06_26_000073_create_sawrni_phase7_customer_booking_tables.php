<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
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
                $table->json('portfolio_urls')->nullable();
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

        $now = now();
        if (DB::table('sawrni_phase7_service_categories')->count() === 0) {
            DB::table('sawrni_phase7_service_categories')->insert([
                ['code' => 'photography', 'name_ar' => 'تصوير', 'name_en' => 'Photography', 'description_ar' => 'جلسات تخرج، أعراس، منتجات، مناسبات.', 'description_en' => 'Graduation, weddings, products, and events.', 'is_active' => true, 'sort_order' => 1, 'created_at' => $now, 'updated_at' => $now],
                ['code' => 'editing', 'name_ar' => 'تعديل صور', 'name_en' => 'Photo Editing', 'description_ar' => 'تحسين، رتوش، ألوان، وتسليم رقمي.', 'description_en' => 'Retouching, color grading, enhancements, and digital delivery.', 'is_active' => true, 'sort_order' => 2, 'created_at' => $now, 'updated_at' => $now],
                ['code' => 'modeling', 'name_ar' => 'مودلز', 'name_en' => 'Models', 'description_ar' => 'مودلز للتصوير التجاري والإعلانات.', 'description_en' => 'Models for commercial shoots and campaigns.', 'is_active' => true, 'sort_order' => 3, 'created_at' => $now, 'updated_at' => $now],
            ]);
        }

        if (DB::table('sawrni_phase7_provider_profiles')->count() === 0) {
            DB::table('sawrni_phase7_provider_profiles')->insert([
                ['display_name' => 'Hussein Photo', 'provider_type' => 'photographer', 'service_type' => 'photography', 'city' => 'Baghdad', 'subscription_plan' => 'premium', 'approval_status' => 'approved', 'debt_balance_iqd' => 0, 'is_suspended' => false, 'rating' => 4.80, 'phone' => '07800000001', 'starting_price_iqd' => 45000, 'bio_ar' => 'مصوّر جلسات تخرج ومناسبات في بغداد.', 'bio_en' => 'Graduation and event photographer in Baghdad.', 'approved_at' => $now, 'created_at' => $now, 'updated_at' => $now],
                ['display_name' => 'Edit Studio', 'provider_type' => 'editor', 'service_type' => 'editing', 'city' => 'Baghdad', 'subscription_plan' => 'standard', 'approval_status' => 'approved', 'debt_balance_iqd' => 25000, 'is_suspended' => false, 'rating' => 4.70, 'phone' => '07800000002', 'starting_price_iqd' => 25000, 'bio_ar' => 'تحرير وتعديل صور بتسليم رقمي.', 'bio_en' => 'Digital photo editing and retouching.', 'approved_at' => $now, 'created_at' => $now, 'updated_at' => $now],
                ['display_name' => 'Pending Studio', 'provider_type' => 'photographer', 'service_type' => 'photography', 'city' => 'Baghdad', 'subscription_plan' => 'basic', 'approval_status' => 'pending', 'debt_balance_iqd' => 0, 'is_suspended' => false, 'rating' => null, 'phone' => '07800000003', 'starting_price_iqd' => 35000, 'bio_ar' => 'مزود بانتظار موافقة COO.', 'bio_en' => 'Provider waiting for COO approval.', 'created_at' => $now, 'updated_at' => $now],
            ]);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('sawrni_phase7_booking_requests');
        Schema::dropIfExists('sawrni_phase7_provider_profiles');
        Schema::dropIfExists('sawrni_phase7_service_categories');
    }
};
