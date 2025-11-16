// services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  // Notificación de recordatorio de asistencia
  Future<void> showAttendanceReminder() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'attendance_channel',
      'Recordatorios de Asistencia',
      channelDescription: 'Recordatorios para registrar asistencia',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      '⏰ Hora de Registrar Asistencia',
      'No olvides registrar tu asistencia/huella para el control diario',
      details,
    );
  }

  // Notificación de recordatorio de huella
  Future<void> showFingerprintReminder() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fingerprint_channel', 
      'Recordatorios de Huella',
      channelDescription: 'Recordatorios para registrar huella digital',
      importance: Importance.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      2,
      '👆 Registra tu Huella',
      'Recuerda registrar tu huella digital para la asistencia',
      details,
    );
  }

  // Programar recordatorios diarios
  Future<void> scheduleDailyReminders() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminders',
      'Recordatorios Diarios',
      channelDescription: 'Recordatorios programados diariamente',
      importance: Importance.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    // Programar para las 7:00 AM
    await _notifications.periodicallyShow(
      10,
      '📚 Buen Día en INCOS',
      '¡Es hora de registrar tu asistencia para comenzar el día!',
      RepeatInterval.daily,
      details,
      // FIX: El parámetro androidScheduleMode ahora es obligatorio.
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // Programar para las 12:00 PM (mediodía)
    await _notifications.periodicallyShow(
      11,
      '🍎 Hora del Almuerzo',
      'Recuerda registrar tu salida y entrada después del almuerzo',
      RepeatInterval.daily,
      details,
      // FIX: El parámetro androidScheduleMode ahora es obligatorio.
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}