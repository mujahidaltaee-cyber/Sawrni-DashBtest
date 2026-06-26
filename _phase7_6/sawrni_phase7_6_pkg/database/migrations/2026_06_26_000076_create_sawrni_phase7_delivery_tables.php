<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (!Schema::hasTable('sawrni_delivery_uploads')) {
            Schema::create('sawrni_delivery_uploads', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('booking_id')->index();
                $table->unsignedBigInteger('provider_id')->nullable()->index();
                $table->unsignedBigInteger('customer_id')->nullable()->index();
                $table->string('title')->nullable();
                $table->text('notes')->nullable();
                $table->string('status')->default('pending_admin_review')->index();
                $table->string('storage_disk')->default('local_private');
                $table->string('file_path')->nullable();
                $table->string('original_filename')->nullable();
                $table->string('mime_type')->nullable();
                $table->unsignedBigInteger('file_size_bytes')->nullable();
                $table->string('latest_access_token_hash')->nullable()->index();
                $table->timestamp('latest_access_expires_at')->nullable();
                $table->timestamp('provider_submitted_at')->nullable();
                $table->timestamp('admin_reviewed_at')->nullable();
                $table->unsignedBigInteger('admin_id')->nullable();
                $table->text('admin_notes')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('sawrni_delivery_access_logs')) {
            Schema::create('sawrni_delivery_access_logs', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('delivery_upload_id')->nullable()->index();
                $table->string('actor_role')->nullable()->index();
                $table->unsignedBigInteger('actor_id')->nullable()->index();
                $table->string('action')->index();
                $table->string('ip_address')->nullable();
                $table->text('user_agent')->nullable();
                $table->json('meta')->nullable();
                $table->timestamp('created_at')->nullable();
            });
        }

        if (!Schema::hasTable('sawrni_delivery_audit_logs')) {
            Schema::create('sawrni_delivery_audit_logs', function (Blueprint $table) {
                $table->id();
                $table->string('actor_role')->nullable()->index();
                $table->unsignedBigInteger('actor_id')->nullable()->index();
                $table->string('event')->index();
                $table->string('subject_type')->nullable();
                $table->unsignedBigInteger('subject_id')->nullable()->index();
                $table->json('payload')->nullable();
                $table->timestamp('created_at')->nullable();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('sawrni_delivery_audit_logs');
        Schema::dropIfExists('sawrni_delivery_access_logs');
        Schema::dropIfExists('sawrni_delivery_uploads');
    }
};
