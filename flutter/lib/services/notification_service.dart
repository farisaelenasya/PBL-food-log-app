import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

enum FrekuensiObat { setiapHari, sekaliSaja, hariTertentu }

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Init ─────────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    // Minta izin notifikasi Android 13+
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

    // Buat notification channels
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        'gula_darah_alert',
        'Alert Gula Darah',
        description: 'Notifikasi saat gula darah naik atau turun',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        'pengingat_obat',
        'Pengingat Obat',
        description: 'Pengingat jadwal minum obat',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    _initialized = true;
  }

  // ── Gula Darah Tinggi ────────────────────────────────────────────────────
  Future<void> kirimNotifGulaTinggi({
    required double nilai,
    required String konteks,
  }) async {
    await _kirim(
      id: 1001,
      channelId: 'gula_darah_alert',
      channelNama: 'Alert Gula Darah',
      judul: '🔴 Gula Darah Terlalu Tinggi!',
      isi:
          'Kadar gula ${nilai.toStringAsFixed(0)} mg/dL saat $konteks. Batasi karbohidrat & tetap aktif.',
      importance: Importance.max,
      priority: Priority.high,
      bigText:
          'Kadar gula darah: ${nilai.toStringAsFixed(0)} mg/dL\nWaktu: $konteks\nBatas normal: di bawah 180 mg/dL\nSaran: Kurangi karbohidrat, minum air putih, olahraga ringan.',
    );
  }

  // ── Gula Darah Rendah ────────────────────────────────────────────────────
  Future<void> kirimNotifGulaRendah({
    required double nilai,
    required String konteks,
  }) async {
    await _kirim(
      id: 1002,
      channelId: 'gula_darah_alert',
      channelNama: 'Alert Gula Darah',
      judul: '⚠️ Gula Darah Terlalu Rendah!',
      isi:
          'Kadar gula ${nilai.toStringAsFixed(0)} mg/dL saat $konteks. Segera konsumsi makanan manis!',
      importance: Importance.max,
      priority: Priority.high,
      bigText:
          'Kadar gula darah: ${nilai.toStringAsFixed(0)} mg/dL\nWaktu: $konteks\nBatas normal: di atas 70 mg/dL\nSaran: Minum jus, makan permen, atau tablet glukosa segera.',
    );
  }

  // ── Gula Darah Normal Kembali ────────────────────────────────────────────
  Future<void> kirimNotifGulaNormal({required double nilai}) async {
    await _kirim(
      id: 1003,
      channelId: 'gula_darah_alert',
      channelNama: 'Alert Gula Darah',
      judul: '✅ Gula Darah Kembali Normal',
      isi:
          'Kadar gula ${nilai.toStringAsFixed(0)} mg/dL — dalam batas normal. Pertahankan! 💪',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
  }

  // ── Pengingat Obat ───────────────────────────────────────────────────────
  Future<void> kirimNotifObat({
    required String namaObat,
    required String dosis,
    required String waktu,
  }) async {
    await _kirim(
      id: 2001,
      channelId: 'pengingat_obat',
      channelNama: 'Pengingat Obat',
      judul: '💊 Waktunya Minum Obat!',
      isi: '$namaObat • $dosis • $waktu',
      importance: Importance.high,
      priority: Priority.high,
    );
  }

// ── Jadwalkan Pengingat Obat (harian, berulang) ─────────────────────────
  Future<void> jadwalkanNotifObat({
    required int id,
    required String namaObat,
    required String dosis,
    required String waktuLabel,
    required int jam,
    required int menit,
    required FrekuensiObat frekuensi,
    List<int>? hariTerpilih,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'pengingat_obat',
      'Pengingat Obat',
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      playSound: true,
      enableVibration: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    switch (frekuensi) {
      case FrekuensiObat.setiapHari:
        await _plugin.zonedSchedule(
          id,
          '💊 Waktunya Minum Obat!',
          '$namaObat • $dosis • $waktuLabel',
          _instanceJamBerikutnya(jam, menit),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        break;

      case FrekuensiObat.sekaliSaja:
        await _plugin.zonedSchedule(
          id,
          '💊 Waktunya Minum Obat!',
          '$namaObat • $dosis • $waktuLabel',
          _instanceJamBerikutnya(jam, menit),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        break;

      case FrekuensiObat.hariTertentu:
        if (hariTerpilih == null || hariTerpilih.isEmpty) return;
        for (final hari in hariTerpilih) {
          await _plugin.zonedSchedule(
            id * 10 + hari,
            '💊 Waktunya Minum Obat!',
            '$namaObat • $dosis • $waktuLabel',
            _instanceHariBerikutnya(hari, jam, menit),
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
        break;
    }
  }

  Future<void> tundaNotifikasi({
    required int id,
    required String namaObat,
    required String dosis,
    int menit = 30,
  }) async {
    final waktuBaru = tz.TZDateTime.now(tz.local).add(Duration(minutes: menit));

    final androidDetails = AndroidNotificationDetails(
      'pengingat_obat',
      'Pengingat Obat',
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      playSound: true,
      enableVibration: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id,
      '💊 Waktunya Minum Obat!',
      '$namaObat • $dosis (ditunda)',
      waktuBaru,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime _instanceJamBerikutnya(int jam, int menit) {
    final sekarang = tz.TZDateTime.now(tz.local);
    var jadwal = tz.TZDateTime(
        tz.local, sekarang.year, sekarang.month, sekarang.day, jam, menit);
    if (jadwal.isBefore(sekarang)) {
      jadwal = jadwal.add(const Duration(days: 1));
    }
    return jadwal;
  }

  tz.TZDateTime _instanceHariBerikutnya(int targetWeekday, int jam, int menit) {
    var jadwal = _instanceJamBerikutnya(jam, menit);
    while (jadwal.weekday != targetWeekday) {
      jadwal = jadwal.add(const Duration(days: 1));
    }
    return jadwal;
  }

// ── Dismiss ──────────────────────────────────────────────────────────────
  Future<void> dismiss(int id) => _plugin.cancel(id);
  Future<void> dismissSemua() => _plugin.cancelAll();

  // ── Internal: kirim notif ────────────────────────────────────────────────
  Future<void> _kirim({
    required int id,
    required String channelId,
    required String channelNama,
    required String judul,
    required String isi,
    required Importance importance,
    required Priority priority,
    String? bigText,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelNama,
      importance: importance,
      priority: priority,
      styleInformation: bigText != null
          ? BigTextStyleInformation(bigText, contentTitle: judul)
          : null,
      fullScreenIntent: importance == Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _plugin.show(
      id,
      judul,
      isi,
      NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
} // ← penutup class NotificationService