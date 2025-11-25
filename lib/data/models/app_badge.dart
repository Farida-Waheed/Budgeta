class AppBadge {
  final String id;
  final String title;
  final String description;
  final bool earned;

  AppBadge({
    required this.id,
    required this.title,
    required this.description,
    this.earned = false,
  });

  AppBadge earn() {
    return AppBadge(
      id: id,
      title: title,
      description: description,
      earned: true,
    );
  }
}
