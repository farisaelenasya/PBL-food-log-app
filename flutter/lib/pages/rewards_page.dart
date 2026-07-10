import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'yoga_video_page.dart';
import 'healthy_meal_page.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  int totalPoin = 0;
  int levelUser = 1;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    try {
      final res = await ApiService.getPoints();

      setState(() {
        totalPoin = res['data']['total_poin'] ?? 0;
        levelUser = res['data']['level_user'] ?? 1;
      });
    } catch (e) {
      print("Error load points: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    int poinPerLevel = 100;
    double progress = (totalPoin % poinPerLevel) / poinPerLevel;
    int sisaPoin = poinPerLevel - (totalPoin % poinPerLevel);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hadiah & Poin',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        actions: [
          
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadPoints,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= LEVEL CARD =================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.blue[100],
                      child: const Icon(Icons.person, size: 36, color: Color(0xFF2979FF)),
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level $levelUser: Pahlawan Kesehatan',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),

                          const SizedBox(height: 2),
                          Text(
                            'Terus catat makanan untuk naik level 🚀',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.grey[200],
                                    color: const Color(0xFF2979FF),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$totalPoin/$poinPerLevel poin',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2979FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '$sisaPoin poin lagi ke Level ${levelUser + 1}',
                            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= RINCIAN POIN =================
              const Text(
                'Rincian Poin',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 10),

              _buildBarisPoin(Icons.check_circle_outline, Colors.blue,
                  'Catatan Makanan', 'Setiap input makanan', '+10 poin', Colors.blue),

              _buildBarisPoin(Icons.water_drop_outlined, Colors.blue,
                  'Catat Gula Darah','Setiap input gula darah','+10 poin',Colors.blue,),

             _buildBarisPoin( Icons.vaccines_outlined, Colors.purple,
                  'Pelacak Insulin','Setiap catat dosis insulin','+10 poin', Colors.purple,),

              const SizedBox(height: 20),

              // ================= HADIAH =================
              const Text(
                'Tukar Hadiah',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 13),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:_buildKartuHadiah(
                    Icons.self_improvement,
                    'Yoga Online Class',
                    'Video stretching & relaksasi',
                    '300 poin',
                    const YogaVideoPage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildKartuHadiah(
                    Icons.restaurant_menu,
                    'Healthy Meal Plan',
                    'Menu 3 hari untuk kontrol gula darah',
                    '400 poin',
                    const HealthyMealPage(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= RINCIAN ROW =================
  Widget _buildBarisPoin(
    IconData ikon,
    Color warnaIkon,
    String judul,
    String subjudul,
    String poin,
    Color warnaPoin,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: warnaIkon.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(ikon, color: warnaIkon, size: 20),
        ),
        title: Text(judul),
        subtitle: Text(subjudul),
        trailing: Text(
          poin,
          style: TextStyle(fontWeight: FontWeight.bold, color: warnaPoin),
        ),
      ),
    );
  }

  // ================= HADIAH CARD =================
  Widget _buildKartuHadiah(
    IconData ikon,
    String judul,
    String subjudul,
    String poin,
    Widget halamanTujuan,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, color: const Color(0xFF2979FF)),
          const SizedBox(height: 10),
          Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subjudul, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
               onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => halamanTujuan),
                );
             },
              child: Text(poin),
            ),
          ),
        ],
      ),
    );
  }
}