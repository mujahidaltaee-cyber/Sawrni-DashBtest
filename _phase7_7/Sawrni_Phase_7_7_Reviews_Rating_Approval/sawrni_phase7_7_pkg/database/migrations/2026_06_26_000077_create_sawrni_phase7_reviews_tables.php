<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (!Schema::hasTable('sawrni_reviews')) {
            Schema::create('sawrni_reviews', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('booking_id')->nullable()->index();
                $table->unsignedBigInteger('customer_id')->nullable()->index();
                $table->unsignedBigInteger('provider_id')->nullable()->index();
                $table->unsignedTinyInteger('rating')->default(5);
                $table->text('comment')->nullable();
                $table->string('status')->default('pending_review')->index(); // pending_review, approved, rejected
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

    public function down(): void
    {
        Schema::dropIfExists('sawrni_review_audit_logs');
        Schema::dropIfExists('sawrni_reviews');
    }
};
