class VoteModel {
  final String id;
  final String pollId;
  final String userId;
  final List<String> optionIds;
  final DateTime votedAt;

  const VoteModel({
    required this.id,
    required this.pollId,
    required this.userId,
    required this.optionIds,
    required this.votedAt,
  });

  VoteModel copyWith({
    String? id,
    String? pollId,
    String? userId,
    List<String>? optionIds,
    DateTime? votedAt,
  }) {
    return VoteModel(
      id: id ?? this.id,
      pollId: pollId ?? this.pollId,
      userId: userId ?? this.userId,
      optionIds: optionIds ?? this.optionIds,
      votedAt: votedAt ?? this.votedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pollId': pollId,
      'userId': userId,
      'optionIds': optionIds,
      'votedAt': votedAt.toIso8601String(),
    };
  }

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      id: json['id'] as String,
      pollId: json['pollId'] as String,
      userId: json['userId'] as String,
      optionIds: List<String>.from(json['optionIds'] as List),
      votedAt: DateTime.parse(json['votedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoteModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'VoteModel(id: $id, pollId: $pollId, userId: $userId, optionIds: $optionIds)';
}
