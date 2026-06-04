<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Jalankan: php artisan migrate
     * 
     * Tambahkan kolom-kolom profil ke tabel users
     * Jika kolom sudah ada dari migration sebelumnya, skip saja kolom itu.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Cek dulu sebelum tambah agar tidak error kalau sudah ada

            if (!Schema::hasColumn('users', 'tanggal_lahir')) {
                $table->date('tanggal_lahir')->nullable()->after('email');
            }
            if (!Schema::hasColumn('users', 'umur')) {
                $table->unsignedTinyInteger('umur')->nullable()->after('tanggal_lahir');
            }
            if (!Schema::hasColumn('users', 'tinggi_badan')) {
                $table->unsignedSmallInteger('tinggi_badan')->nullable()->after('umur');
            }
            if (!Schema::hasColumn('users', 'berat_badan')) {
                $table->unsignedSmallInteger('berat_badan')->nullable()->after('tinggi_badan');
            }
            if (!Schema::hasColumn('users', 'jenis_kelamin')) {
                $table->string('jenis_kelamin', 20)->nullable()->after('berat_badan');
            }
            if (!Schema::hasColumn('users', 'tipe_diabetes')) {
                $table->string('tipe_diabetes', 30)->nullable()->after('jenis_kelamin');
            }
            if (!Schema::hasColumn('users', 'no_telepon')) {
                $table->string('no_telepon', 20)->nullable()->after('tipe_diabetes');
            }
            if (!Schema::hasColumn('users', 'kontak_darurat')) {
                $table->string('kontak_darurat', 255)->nullable()->after('no_telepon');
            }
            if (!Schema::hasColumn('users', 'golongan_darah')) {
                $table->string('golongan_darah', 5)->nullable()->after('kontak_darurat');
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'tanggal_lahir', 'umur', 'tinggi_badan', 'berat_badan',
                'jenis_kelamin', 'tipe_diabetes', 'no_telepon',
                'kontak_darurat', 'golongan_darah',
            ]);
        });
    }
};