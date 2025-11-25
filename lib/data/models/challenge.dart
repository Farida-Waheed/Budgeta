class Challenge {
  final String id;
  final String title;
  final String description;
  final int target;
  final int progress;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    this.progress = 0,
  });

  double get percentage => progress / target;

  Challenge updateProgress(int amount) {
    return Challenge(
      id: id,
      title: title,
      description: description,
      target: target,
      progress: progress + amount,
    );
  }
}
