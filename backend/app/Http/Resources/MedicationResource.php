<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MedicationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'              => $this->id,
            'nama_obat'       => $this->nama_obat,
            'dosis'           => $this->dosis,
            'frekuensi'       => $this->frekuensi,
            'waktu_konsumsi'  => $this->waktu_konsumsi,
            'tipe'            => $this->tipe,
            'catatan'         => $this->catatan,
            'dibuat_pada'     => $this->created_at?->toIso8601String(),
            'diperbarui_pada' => $this->updated_at?->toIso8601String(),
            'hari_terpilih' => $this->hari_terpilih ?? [],
        ];
    }
}