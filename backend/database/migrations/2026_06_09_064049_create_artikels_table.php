<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('artikel', function (Blueprint $table) {
    $table->id();
    $table->string('judul');
    $table->string('kategori');
    $table->text('isi');
    $table->text('link_artikel')->nullable();
    $table->boolean('diterbitkan')->default(true);
    $table->timestamps();
});
    }

    public function down(): void
    {
        Schema::dropIfExists('artikel');
    }
};