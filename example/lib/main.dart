import 'dart:async';

import 'package:chat_poll_kit/chat_poll_kit.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Mock adapter for demo (no backend needed)
// ---------------------------------------------------------------------------
class MockPollAdapter implements PollDataSource {
  final Map<String, PollModel> _polls = {};
  final Map<String, List<VoteModel>> _votes = {};
  final Map<String, StreamController<PollModel>> _controllers = {};

  MockPollAdapter(List<PollModel> polls) {
    for (final poll in polls) {
      _polls[poll.id] = poll;
      _votes[poll.id] = [];
    }
  }

  @override
  Future<PollModel> getPoll(String pollId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final poll = _polls[pollId];
    if (poll == null) throw Exception('Poll not found: $pollId');
    return poll;
  }

  @override
  Stream<PollModel> watchPoll(String pollId) {
    _controllers[pollId]?.close();
    final controller = StreamController<PollModel>();
    _controllers[pollId] = controller;

    Future<void>.delayed(const Duration(milliseconds: 200)).then((_) {
      final poll = _polls[pollId];
      if (poll != null && !controller.isClosed) {
        controller.add(poll);
      }
    });

    return controller.stream;
  }

  @override
  Future<void> submitVote({
    required String pollId,
    required String userId,
    required List<String> optionIds,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final poll = _polls[pollId];
    if (poll == null) throw Exception('Poll not found');

    final updated = poll.copyWith(
      options: poll.options.map((o) {
        if (optionIds.contains(o.id)) {
          return o.copyWith(votes: o.votes + 1);
        }
        return o;
      }).toList(),
    );
    _polls[pollId] = updated;

    final vote = VoteModel(
      id: 'vote_${DateTime.now().millisecondsSinceEpoch}',
      pollId: pollId,
      userId: userId,
      optionIds: optionIds,
      votedAt: DateTime.now(),
    );
    _votes[pollId] = [...(_votes[pollId] ?? []), vote];

    // Push update to stream
    _controllers[pollId]?.add(updated);
  }

  @override
  Future<bool> hasUserVoted({
    required String pollId,
    required String userId,
  }) async {
    final votes = _votes[pollId] ?? [];
    return votes.any((v) => v.userId == userId);
  }

  @override
  Future<List<VoteModel>> getUserVotes({
    required String pollId,
    required String userId,
  }) async {
    final votes = _votes[pollId] ?? [];
    return votes.where((v) => v.userId == userId).toList();
  }
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------
final _singleChoicePoll = PollModel(
  id: 'poll_1',
  question: 'What is your favourite programming language?',
  options: const [
    PollOption(id: 'opt_1', text: 'Dart', votes: 12),
    PollOption(id: 'opt_2', text: 'Kotlin', votes: 8),
    PollOption(id: 'opt_3', text: 'Swift', votes: 5),
    PollOption(id: 'opt_4', text: 'TypeScript', votes: 15),
  ],
  createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  expiresAt: DateTime.now().add(const Duration(hours: 1)),
);

final _multiChoicePoll = PollModel(
  id: 'poll_2',
  question: 'Which tools do you use daily? (select all that apply)',
  options: const [
    PollOption(id: 'opt_a', text: 'VS Code', votes: 22),
    PollOption(id: 'opt_b', text: 'Android Studio', votes: 14),
    PollOption(id: 'opt_c', text: 'Xcode', votes: 7),
    PollOption(id: 'opt_d', text: 'Terminal / CLI', votes: 18),
  ],
  allowMultipleChoices: true,
  createdAt: DateTime.now().subtract(const Duration(hours: 5)),
);

final _expiredPoll = PollModel(
  id: 'poll_3',
  question: 'Should we adopt Flutter for the new project?',
  options: const [
    PollOption(id: 'opt_yes', text: 'Yes', votes: 31),
    PollOption(id: 'opt_no', text: 'No', votes: 9),
    PollOption(id: 'opt_maybe', text: 'Maybe later', votes: 4),
  ],
  createdAt: DateTime.now().subtract(const Duration(days: 2)),
  expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
);

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------
void main() {
  runApp(const ChatPollExampleApp());
}

class ChatPollExampleApp extends StatefulWidget {
  const ChatPollExampleApp({super.key});

  @override
  State<ChatPollExampleApp> createState() => _ChatPollExampleAppState();
}

class _ChatPollExampleAppState extends State<ChatPollExampleApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Poll Kit Demo',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: ChatPollDemoScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: () => setState(() => _isDarkMode = !_isDarkMode),
      ),
    );
  }
}

class ChatPollDemoScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  ChatPollDemoScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  late final _adapter = MockPollAdapter([
    _singleChoicePoll,
    _multiChoicePoll,
    _expiredPoll,
  ]);

  @override
  Widget build(BuildContext context) {
    final pollTheme = isDarkMode ? PollTheme.dark() : PollTheme.light();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Poll Kit'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label('Single Choice'),
          ChatPollWidget(
            dataSource: _adapter,
            pollId: 'poll_1',
            userId: 'user_demo',
            theme: pollTheme,
            onVoted: (ids) => _showSnack(context, 'Voted: $ids'),
          ),
          const SizedBox(height: 24),
          _label('Multi Choice'),
          ChatPollWidget(
            dataSource: _adapter,
            pollId: 'poll_2',
            userId: 'user_demo',
            theme: pollTheme,
            onVoted: (ids) => _showSnack(context, 'Voted: $ids'),
          ),
          const SizedBox(height: 24),
          _label('Expired Poll'),
          ChatPollWidget(
            dataSource: _adapter,
            pollId: 'poll_3',
            userId: 'user_demo',
            theme: pollTheme,
          ),
          const SizedBox(height: 40),

          // -----------------------------------------------------------------
          // Firebase example (commented out)
          // -----------------------------------------------------------------
          // To use Firebase, replace MockPollAdapter with:
          //
          // final firebaseAdapter = FirebasePollAdapter(
          //   firestore: FirebaseFirestore.instance,
          //   pollsCollection: 'polls',
          //   votesCollection: 'votes',
          // );
          //
          // ChatPollWidget(
          //   dataSource: firebaseAdapter,
          //   pollId: 'your-poll-id',
          //   userId: FirebaseAuth.instance.currentUser!.uid,
          //   theme: pollTheme,
          // ),
          //
          // For REST API, use RestPollAdapter:
          //
          // final restAdapter = RestPollAdapter(
          //   dio: Dio(BaseOptions(baseUrl: 'https://api.example.com')),
          //   baseEndpoint: '/api/polls',
          //   pollingInterval: Duration(seconds: 5),
          // );
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
