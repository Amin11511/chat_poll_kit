import 'poll_option.dart';

class PollModel {
  final String id;
  final String question;
  final List<PollOption> options;
  final bool allowMultipleChoices;
  final bool allowVoteChange;
  final DateTime? expiresAt;
  final DateTime createdAt;

  const PollModel({
    required this.id,
    required this.question,
    required this.options,
    this.allowMultipleChoices = false,
    this.allowVoteChange = false,
    this.expiresAt,
    required this.createdAt,
  });

  int get totalVotes => options.fold(0, (sum, o) => sum + o.votes);

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Duration? get remainingTime {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  PollModel copyWith({
    String? id,
    String? question,
    List<PollOption>? options,
    bool? allowMultipleChoices,
    bool? allowVoteChange,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return PollModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      allowMultipleChoices: allowMultipleChoices ?? this.allowMultipleChoices,
      allowVoteChange: allowVoteChange ?? this.allowVoteChange,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options.map((o) => o.toJson()).toList(),
      'allowMultipleChoices': allowMultipleChoices,
      'allowVoteChange': allowVoteChange,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PollModel.fromJson(Map<String, dynamic> json) {
    return PollModel(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List)
          .map((o) => PollOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      allowMultipleChoices: json['allowMultipleChoices'] as bool? ?? false,
      allowVoteChange: json['allowVoteChange'] as bool? ?? false,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PollModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PollModel(id: $id, question: $question, options: ${options.length})';
}
