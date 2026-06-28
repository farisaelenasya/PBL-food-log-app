<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
   public function up(): void
{
    Schema::table('glucoses', function (Blueprint $table) {
        $table->string('kategori')->nullable()->after('glucose_level');
        $table->text('catatan')->nullable()->after('kategori');
    });
}

public function down(): void
{
    Schema::table('glucoses', function (Blueprint $table) {
        $table->dropColumn(['kategori', 'catatan']);
    });
}
};
