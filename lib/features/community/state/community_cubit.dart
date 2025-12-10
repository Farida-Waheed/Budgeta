// lib/features/community/state/community_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/post.dart';
import '../../../core/models/group_challenge.dart';
import '../data/community_repository.dart';

class CommunityState {
  final bool isLoading;
  final String? errorMessage;
  final List<Post> feed;
  final List<Map<String, dynamic>> leaderboard;
  final List<GroupChallenge> groupChallenges;

  const CommunityState({
    required this.isLoading,
    required this.errorMessage,
    required this.feed,
    required this.leaderboard,
    required this.groupChallenges,
  });

  factory CommunityState.initial() => const CommunityState(
    isLoading: false,
    errorMessage: null,
    feed: [],
    leaderboard: [],
    groupChallenges: [],
  );

  CommunityState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Post>? feed,
    List<Map<String, dynamic>>? leaderboard,
    List<GroupChallenge>? groupChallenges,
  }) {
    return CommunityState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      feed: feed ?? this.feed,
      leaderboard: leaderboard ?? this.leaderboard,
      groupChallenges: groupChallenges ?? this.groupChallenges,
    );
  }
}

class CommunityCubit extends Cubit<CommunityState> {
  final CommunityRepository repository;
  final String userId;
  final String userName;

  CommunityCubit({
    required this.repository,
    required this.userId,
    this.userName = 'You',
  }) : super(CommunityState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final feed = await repository.getFeed(userId: userId);
      final leaderboard = await repository.getLeaderboard();
      final challenges = await repository.getGroupChallenges(userId: userId);

      emit(
        state.copyWith(
          isLoading: false,
          feed: feed,
          leaderboard: leaderboard,
          groupChallenges: challenges,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load community right now.',
        ),
      );
    }
  }

  Future<void> refreshFeed() async {
    try {
      final feed = await repository.getFeed(userId: userId);
      emit(state.copyWith(feed: feed));
    } catch (_) {}
  }

  Future<void> createPost(String text, {double? attachedProgress}) async {
    if (text.trim().isEmpty) return;
    try {
      final newPost = await repository.createPost(
        userId: userId,
        userName: userName,
        text: text,
        attachedProgress: attachedProgress,
      );
      emit(state.copyWith(feed: [newPost, ...state.feed]));
    } catch (_) {}
  }

  Future<void> toggleLike(String postId) async {
    try {
      final updated = await repository.toggleLike(
        userId: userId,
        postId: postId,
      );
      final updatedFeed = state.feed
          .map((p) => p.id == updated.id ? updated : p)
          .toList();
      emit(state.copyWith(feed: updatedFeed));
    } catch (_) {}
  }

  Future<void> addComment(String postId, String text) async {
    if (text.trim().isEmpty) return;
    try {
      final updated = await repository.addComment(
        userId: userId,
        userName: userName,
        postId: postId,
        text: text,
      );
      final updatedFeed = state.feed
          .map((p) => p.id == updated.id ? updated : p)
          .toList();
      emit(state.copyWith(feed: updatedFeed));
    } catch (_) {}
  }

  Future<void> joinGroupChallenge(String challengeId) async {
    try {
      final updated = await repository.joinGroupChallenge(
        userId: userId,
        challengeId: challengeId,
      );
      final updatedList = state.groupChallenges
          .map((c) => c.id == updated.id ? updated : c)
          .toList();
      emit(state.copyWith(groupChallenges: updatedList));
    } catch (_) {}
  }

  Future<void> reportContent({
    required String postId,
    required String reason,
    String? details,
  }) async {
    try {
      await repository.reportContent(
        userId: userId,
        postId: postId,
        reason: reason,
        details: details,
      );
    } catch (_) {}
  }

  Post? findPostById(String id) {
    try {
      return state.feed.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
