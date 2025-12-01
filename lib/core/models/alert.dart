// lib/core/models/alert.dart
enum AlertType { overspent, upcomingBill, lowBalance, goalOffTrack }

class Alert {
  final String id;
  final String userId;
  final AlertType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  Alert({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });
}
