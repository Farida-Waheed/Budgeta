// lib/core/services/notification_service.dart
abstract class NotificationService {
  Future<void> init();

  Future<void> showSimpleNotification({
    required String id,
    required String title,
    required String body,
  });

  Future<void> cancelNotification(String id);
}
