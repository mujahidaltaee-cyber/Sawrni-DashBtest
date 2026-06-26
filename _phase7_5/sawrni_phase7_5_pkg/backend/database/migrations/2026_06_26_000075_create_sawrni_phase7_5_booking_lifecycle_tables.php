<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
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

                $table->index(['provider_id', 'status']);
                $table->index(['customer_id', 'status']);
                $table->index('scheduled_at');
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

                $table->index(['booking_id', 'event_type']);
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('sawrni_booking_events');
        Schema::dropIfExists('sawrni_mobile_bookings');
    }
};
