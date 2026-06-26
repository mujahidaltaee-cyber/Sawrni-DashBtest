<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        if (!Schema::hasTable('sawrni_mobile_otps')) {
            Schema::create('sawrni_mobile_otps', function (Blueprint $table) {
                $table->id();
                $table->string('phone')->index();
                $table->string('role')->index();
                $table->string('purpose')->default('login');
                $table->string('otp_hash');
                $table->string('status')->default('pending')->index();
                $table->unsignedInteger('attempts')->default(0);
                $table->timestamp('expires_at')->nullable()->index();
                $table->timestamp('consumed_at')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('sawrni_mobile_sessions')) {
            Schema::create('sawrni_mobile_sessions', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('user_id')->nullable()->index();
                $table->string('phone')->index();
                $table->string('role')->index();
                $table->string('token_hash')->unique();
                $table->string('device_name')->nullable();
                $table->timestamp('expires_at')->nullable()->index();
                $table->timestamp('revoked_at')->nullable()->index();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('sawrni_mobile_audit_events')) {
            Schema::create('sawrni_mobile_audit_events', function (Blueprint $table) {
                $table->id();
                $table->string('actor_type')->nullable()->index();
                $table->string('actor_phone')->nullable()->index();
                $table->string('event')->index();
                $table->string('ip_address')->nullable();
                $table->text('user_agent')->nullable();
                $table->text('payload')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('sawrni_provider_profiles_secure')) {
            Schema::create('sawrni_provider_profiles_secure', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('user_id')->nullable()->index();
                $table->string('phone')->nullable()->index();
                $table->string('display_name')->nullable();
                $table->string('provider_type')->nullable()->index(); // photographer/editor/model
                $table->string('category')->nullable()->index();
                $table->string('city')->nullable()->index();
                $table->string('subscription_plan')->default('basic')->index();
                $table->string('approval_status')->default('pending')->index();
                $table->unsignedBigInteger('debt_balance_iqd')->default(0);
                $table->boolean('is_suspended')->default(false)->index();
                $table->decimal('rating', 3, 2)->nullable();
                $table->text('bio')->nullable();
                $table->text('public_portfolio_note')->nullable();
                $table->text('private_contact_note')->nullable();
                $table->timestamp('approved_at')->nullable();
                $table->timestamps();
            });
        } else {
            $columns = [
                'user_id' => fn(Blueprint $t) => $t->unsignedBigInteger('user_id')->nullable()->index(),
                'phone' => fn(Blueprint $t) => $t->string('phone')->nullable()->index(),
                'display_name' => fn(Blueprint $t) => $t->string('display_name')->nullable(),
                'provider_type' => fn(Blueprint $t) => $t->string('provider_type')->nullable()->index(),
                'category' => fn(Blueprint $t) => $t->string('category')->nullable()->index(),
                'city' => fn(Blueprint $t) => $t->string('city')->nullable()->index(),
                'subscription_plan' => fn(Blueprint $t) => $t->string('subscription_plan')->default('basic')->index(),
                'approval_status' => fn(Blueprint $t) => $t->string('approval_status')->default('pending')->index(),
                'debt_balance_iqd' => fn(Blueprint $t) => $t->unsignedBigInteger('debt_balance_iqd')->default(0),
                'is_suspended' => fn(Blueprint $t) => $t->boolean('is_suspended')->default(false)->index(),
                'rating' => fn(Blueprint $t) => $t->decimal('rating', 3, 2)->nullable(),
                'bio' => fn(Blueprint $t) => $t->text('bio')->nullable(),
                'public_portfolio_note' => fn(Blueprint $t) => $t->text('public_portfolio_note')->nullable(),
                'private_contact_note' => fn(Blueprint $t) => $t->text('private_contact_note')->nullable(),
                'approved_at' => fn(Blueprint $t) => $t->timestamp('approved_at')->nullable(),
            ];

            foreach ($columns as $column => $callback) {
                if (!Schema::hasColumn('sawrni_provider_profiles_secure', $column)) {
                    Schema::table('sawrni_provider_profiles_secure', function (Blueprint $table) use ($callback) {
                        $callback($table);
                    });
                }
            }
        }
    }

    public function down(): void
    {
        // Keep provider profiles; this migration is intended as forward-only project foundation.
        Schema::dropIfExists('sawrni_mobile_audit_events');
        Schema::dropIfExists('sawrni_mobile_sessions');
        Schema::dropIfExists('sawrni_mobile_otps');
    }
};
