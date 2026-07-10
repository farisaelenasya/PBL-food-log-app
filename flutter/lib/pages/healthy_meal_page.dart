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
      backgroundColor: const Color(0xFFF5F7FA),
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
      children: [
        const Text(
          "Healthy Meal Plan Harian",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        const SizedBox(height: 4),
        Text(
          "Menu 3 hari untuk bantu kontrol gula darah",
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 18),

        _buildMealCard(
          icon: Icons.wb_sunny_outlined,
          iconColor: Colors.orange,
          title: "Sarapan",
          items: const [
            "Oatmeal + susu rendah gula",
            "Telur rebus",
            "Teh tanpa gula",
          ],
        ),

        _buildMealCard(
          icon: Icons.lunch_dining_outlined,
          iconColor: Colors.green,
          title: "Makan Siang",
          items: const [
            "Nasi merah",
            "Ayam panggang / rebus",
            "Sayur bayam / brokoli",
            "Tahu / tempe",
          ],
        ),

        _buildMealCard(
          icon: Icons.nightlight_outlined,
          iconColor: Colors.indigo,
          title: "Makan Malam",
          items: const [
            "Sup sayur",
            "Ikan panggang",
            "Salad sayur",
          ],
        ),

        _buildMealCard(
          icon: Icons.eco_outlined,
          iconColor: Colors.teal,
          title: "Snack Sehat",
          items: const [
            "Apel",
            "Kacang almond",
            "Yogurt plain",
          ],
        ),

        _buildMealCard(
          icon: Icons.warning_amber_outlined,
          iconColor: Colors.red,
          title: "Hindari",
          items: const [
            "Minuman manis",
            "Gorengan",
            "Nasi putih berlebihan",
          ],
          isWarning: true,
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  // ================= MEAL CARD =================
  Widget _buildMealCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
    bool isWarning = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isWarning ? Icons.close : Icons.check,
                    size: 16,
                    color: isWarning ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}