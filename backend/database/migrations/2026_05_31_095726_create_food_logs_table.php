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
        Schema::create('food_logs', function (Blueprint $table) {
    $table->id();

    $table->string('nama_makanan');
    $table->double('gram')->nullable();

    $table->string('waktu_makan')->nullable();

    $table->double('kalori')->default(0);
    $table->double('karbo')->default(0);
    $table->double('protein')->default(0);
    $table->double('lemak')->default(0);
    $table->double('serat')->default(0);
    $table->double('gula')->default(0);

    $table->integer('indeks_glikemik')->default(50);

    $table->string('foto_path')->nullable();
    $table->timestamp('dicatat_pada')->nullable();

    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('food_logs');
    }
};
