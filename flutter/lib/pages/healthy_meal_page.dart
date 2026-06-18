import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HealthyMealPage extends StatefulWidget {
  const HealthyMealPage({super.key});

  @override
  State<HealthyMealPage> createState() => _HealthyMealPageState();
}

class _HealthyMealPageState extends State<HealthyMealPage> {
  int userPoints = 0;
  bool canAccess = false;

  @override
  void initState() {
    super.initState();
    loadPoints();
  }

  Future<void> loadPoints() async {
    final data = await ApiService.getPoints();

    setState(() {
      userPoints = data['data']['total_poin'] ?? 0;
      canAccess = userPoints >= 400;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Healthy Meal Plan"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: canAccess ? _buildMealPlan() : _buildLocked(),
      ),
    );
  }

  // 🔒 LOCK SCREEN
  Widget _buildLocked() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            const Text(
              "Healthy Meal Plan Terkunci",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text("Poin kamu: $userPoints / 400"),
          ],
        ),
      ),
    );
  }

  // 🍽 MEAL PLAN CONTENT
  Widget _buildMealPlan() {
    return ListView(
      children: const [
        Text(
          "🍽 Healthy Meal Plan Harian",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 20),

        Text("🍳 Sarapan"),
        Text("- Oatmeal + susu rendah gula"),
        Text("- Telur rebus"),
        Text("- Teh tanpa gula"),

        SizedBox(height: 15),

        Text("🍱 Makan Siang"),
        Text("- Nasi merah"),
        Text("- Ayam panggang / rebus"),
        Text("- Sayur bayam / brokoli"),
        Text("- Tahu / tempe"),

        SizedBox(height: 15),

        Text("🌙 Makan Malam"),
        Text("- Sup sayur"),
        Text("- Ikan panggang"),
        Text("- Salad sayur"),

        SizedBox(height: 15),

        Text("🍎 Snack Sehat"),
        Text("- Apel"),
        Text("- Kacang almond"),
        Text("- Yogurt plain"),

        SizedBox(height: 15),

        Text("⚠️ Hindari"),
        Text("- Minuman manis"),
        Text("- Gorengan"),
        Text("- Nasi putih berlebihan"),
      ],
    );
  }
}