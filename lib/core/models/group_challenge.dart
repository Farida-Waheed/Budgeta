// lib/core/models/group_challenge.dart
class GroupChallenge {
  final String id;
  final String name;
  final String description;
  final int memberCount;
  final bool isJoined;
  final int? myRank;
  final double? teamProgress; // 0..1

  const GroupChallenge({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
    this.isJoined = false,
    this.myRank,
    this.teamProgress,
  });

  GroupChallenge copyWith({
    String? id,
    String? name,
    String? description,
    int? memberCount,
    bool? isJoined,
    int? myRank,
    double? teamProgress,
  }) {
    return GroupChallenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      memberCount: memberCount ?? this.memberCount,
      isJoined: isJoined ?? this.isJoined,
      myRank: myRank ?? this.myRank,
      teamProgress: teamProgress ?? this.teamProgress,
    );
  }
}
