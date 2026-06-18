<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use App\Http\Controllers\Api\PointController;
class FoodVisionController extends Controller
{
    public function detectFood(Request $request)
    {
        $request->validate([
            'image' => 'required'
        ]);

        $apiKey = env('GOOGLE_VISION_API_KEY');

        $image = base64_encode(file_get_contents($request->file('image')));

        $response = Http::post(
            "https://vision.googleapis.com/v1/images:annotate?key=$apiKey",
            [
                "requests" => [
                    [
                        "image" => [
                            "content" => $image
                        ],
                        "features" => [
                            [
                                "type" => "LABEL_DETECTION",
                                "maxResults" => 10
                            ]
                        ]
                    ]
                ]
            ]
        );

        return response()->json($response->json());
    }
}