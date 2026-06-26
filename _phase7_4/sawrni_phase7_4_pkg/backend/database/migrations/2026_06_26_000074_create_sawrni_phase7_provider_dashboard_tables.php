<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (!Schema::hasTable('sawrni_phase7_booking_requests')) {
            Schema::create('sawrni_phase7_booking_requests', function (Blueprint $table) {
                $table->id();
                $table->string('reference')->unique();
                $table->unsignedBigInteger('customer_id')->nullable();
                $table->unsignedBigInteger('provider_id')->nullable();
                $table->string('customer_name')->nullable();
                $table->string('customer_phone')->nullable();
                $table->string('masked_phone')->nullable();
                $table->string('title_ar')->nullable();
                $table->string('title_en')->nullable();
                $table->string('service_type')->nullable();
                $table->integer('total_amount_iqd')->default(0);
                $table->integer('deposit_amount_iqd')->default(0);
                $table->integer('final_price_iqd')->default(0);
                $table->integer('platform_commission_iqd')->default(0);
                $table->string('status')->default('pending_provider_review');
                $table->timestamp('scheduled_at')->nullable();
                $table->text('notes')->nullable();
                $table->timestamp('provider_responded_at')->nullable();
                $table->text('provider_rejection_reason')->nullable();
                $table->timestamps();

                $table->index(['provider_id', 'status']);
                $table->index(['customer_id', 'status']);
            });
        }

        if (!Schema::hasTable('sawrni_phase7_booking_audit_logs')) {
            Schema::create('sawrni_phase7_booking_audit_logs', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('booking_id')->nullable();
                $table->string('actor_type')->nullable();
                $table->unsignedBigInteger('actor_id')->nullable();
                $table->string('action');
                $table->json('metadata')->nullable();
                $table->timestamps();

                $table->index(['booking_id', 'action']);
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('sawrni_phase7_booking_audit_logs');
        Schema::dropIfExists('sawrni_phase7_booking_requests');
    }
};
