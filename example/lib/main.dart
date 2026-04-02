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
  question: 'Which tools do you use daily? (select all)',
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

final _votedPoll = PollModel(
  id: 'poll_4',
  question: 'Best state management for Flutter?',
  options: const [
    PollOption(id: 'opt_bloc', text: 'BLoC / Cubit', votes: 45),
    PollOption(id: 'opt_riverpod', text: 'Riverpod', votes: 38),
    PollOption(id: 'opt_provider', text: 'Provider', votes: 22),
    PollOption(id: 'opt_getx', text: 'GetX', votes: 15),
  ],
  createdAt: DateTime.now().subtract(const Duration(hours: 10)),
);

// ---------------------------------------------------------------------------
// Custom Themes
// ---------------------------------------------------------------------------
final _greenTheme = PollTheme.light().copyWith(
  backgroundColor: const Color(0xFFF1F8E9),
  questionColor: const Color(0xFF1B5E20),
  optionTextColor: const Color(0xFF2E7D32),
  optionBackgroundColor: const Color(0xFFE8F5E9),
  optionSelectedColor: const Color(0xFFC8E6C9),
  progressBarColor: const Color(0xFF43A047),
  progressBarBackgroundColor: const Color(0xFFDCEDC8),
  percentageColor: const Color(0xFF558B2F),
  checkIconColor: const Color(0xFF43A047),
  footerTextColor: const Color(0xFF689F38),
  countdownColor: const Color(0xFFE65100),
  containerBorderRadius: BorderRadius.circular(16),
  optionBorderRadius: BorderRadius.circular(12),
  progressBarHeight: 8,
  questionTextStyle: const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1B5E20),
  ),
  optionTextStyle: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: Color(0xFF2E7D32),
  ),
);

final _purpleTheme = PollTheme.light().copyWith(
  backgroundColor: const Color(0xFFF3E5F5),
  questionColor: const Color(0xFF4A148C),
  optionTextColor: const Color(0xFF6A1B9A),
  optionBackgroundColor: const Color(0xFFE1BEE7),
  optionSelectedColor: const Color(0xFFCE93D8),
  progressBarColor: const Color(0xFF8E24AA),
  progressBarBackgroundColor: const Color(0xFFE1BEE7),
  percentageColor: const Color(0xFF7B1FA2),
  checkIconColor: const Color(0xFF8E24AA),
  footerTextColor: const Color(0xFF9C27B0),
  countdownColor: const Color(0xFFFF6F00),
  containerBorderRadius: BorderRadius.circular(20),
  optionBorderRadius: BorderRadius.circular(14),
  progressBarHeight: 7,
  optionSpacing: 10,
  questionTextStyle: const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Color(0xFF4A148C),
  ),
  optionTextStyle: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: Color(0xFF6A1B9A),
  ),
);

final _orangeTheme = PollTheme.light().copyWith(
  backgroundColor: const Color(0xFFFFF3E0),
  questionColor: const Color(0xFFE65100),
  optionTextColor: const Color(0xFFBF360C),
  optionBackgroundColor: const Color(0xFFFFE0B2),
  optionSelectedColor: const Color(0xFFFFCC80),
  progressBarColor: const Color(0xFFF57C00),
  progressBarBackgroundColor: const Color(0xFFFFE0B2),
  percentageColor: const Color(0xFFE65100),
  checkIconColor: const Color(0xFFF57C00),
  footerTextColor: const Color(0xFFFF8F00),
  countdownColor: const Color(0xFFD84315),
  containerBorderRadius: BorderRadius.circular(14),
  optionBorderRadius: BorderRadius.circular(10),
  progressBarHeight: 6,
  questionTextStyle: const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Color(0xFFE65100),
  ),
  optionTextStyle: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: Color(0xFFBF360C),
  ),
);

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------
void main() {
  runApp(const ChatPollExampleApp());
}

class ChatPollExampleApp extends StatelessWidget {
  const ChatPollExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Poll Kit Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2196F3),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF64B5F6),
        useMaterial3: true,
      ),
      home: const ScreenshotDemoScreen(),
    );
  }
}

class ScreenshotDemoScreen extends StatefulWidget {
  const ScreenshotDemoScreen({super.key});

  @override
  State<ScreenshotDemoScreen> createState() => _ScreenshotDemoScreenState();
}

class _ScreenshotDemoScreenState extends State<ScreenshotDemoScreen> {
  int _currentPage = 0;

  List<PollModel> get _allPolls => [
        _singleChoicePoll,
        _multiChoicePoll,
        _expiredPoll,
        _votedPoll,
      ];

  late final _lightAdapter = MockPollAdapter(_allPolls);
  late final _darkAdapter = MockPollAdapter(_allPolls);
  late final _greenAdapter = MockPollAdapter(_allPolls);
  late final _purpleAdapter = MockPollAdapter(_allPolls);

  // Pre-vote poll_4 for the "voted" screenshot
  late final _votedAdapter = MockPollAdapter([_votedPoll])
    ..submitVote(
      pollId: 'poll_4',
      userId: 'user_demo',
      optionIds: ['opt_bloc'],
    );

  final _pageTitles = [
    'Light Theme',
    'Dark Theme',
    'Green Custom',
    'Purple Custom',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('chat_poll_kit — ${_pageTitles[_currentPage]}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentPage,
        children: [
          _buildLightPage(),
          _buildDarkPage(),
          _buildGreenPage(),
          _buildPurplePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentPage,
        onDestinationSelected: (i) => setState(() => _currentPage = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.light_mode), label: 'Light'),
          NavigationDestination(icon: Icon(Icons.dark_mode), label: 'Dark'),
          NavigationDestination(icon: Icon(Icons.eco), label: 'Green'),
          NavigationDestination(
              icon: Icon(Icons.color_lens), label: 'Purple'),
        ],
      ),
    );
  }

  Widget _buildLightPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionLabel('Single Choice Poll', Colors.black87),
        ChatPollWidget(
          dataSource: _lightAdapter,
          pollId: 'poll_1',
          userId: 'user_demo',
          theme: PollTheme.light(),
        ),
        const SizedBox(height: 20),
        _sectionLabel('Multi Choice Poll', Colors.black87),
        ChatPollWidget(
          dataSource: _lightAdapter,
          pollId: 'poll_2',
          userId: 'user_demo',
          theme: PollTheme.light(),
        ),
        const SizedBox(height: 20),
        _sectionLabel('Expired Poll', Colors.black87),
        ChatPollWidget(
          dataSource: _lightAdapter,
          pollId: 'poll_3',
          userId: 'user_demo',
          theme: PollTheme.light(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDarkPage() {
    return Container(
      color: const Color(0xFF121212),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('Single Choice Poll', Colors.white70),
          ChatPollWidget(
            dataSource: _darkAdapter,
            pollId: 'poll_1',
            userId: 'user_dark',
            theme: PollTheme.dark(),
          ),
          const SizedBox(height: 20),
          _sectionLabel('Voted Poll (with results)', Colors.white70),
          ChatPollWidget(
            dataSource: _votedAdapter,
            pollId: 'poll_4',
            userId: 'user_demo',
            theme: PollTheme.dark(),
          ),
          const SizedBox(height: 20),
          _sectionLabel('Expired Poll', Colors.white70),
          ChatPollWidget(
            dataSource: _darkAdapter,
            pollId: 'poll_3',
            userId: 'user_dark',
            theme: PollTheme.dark(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGreenPage() {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('Single Choice', const Color(0xFF1B5E20)),
          ChatPollWidget(
            dataSource: _greenAdapter,
            pollId: 'poll_1',
            userId: 'user_green',
            theme: _greenTheme,
          ),
          const SizedBox(height: 20),
          _sectionLabel('Multi Choice', const Color(0xFF1B5E20)),
          ChatPollWidget(
            dataSource: _greenAdapter,
            pollId: 'poll_2',
            userId: 'user_green',
            theme: _greenTheme,
          ),
          const SizedBox(height: 20),
          _sectionLabel('Expired', const Color(0xFF1B5E20)),
          ChatPollWidget(
            dataSource: _greenAdapter,
            pollId: 'poll_3',
            userId: 'user_green',
            theme: _greenTheme,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPurplePage() {
    return Container(
      color: const Color(0xFFF3E5F5),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('Single Choice', const Color(0xFF4A148C)),
          ChatPollWidget(
            dataSource: _purpleAdapter,
            pollId: 'poll_1',
            userId: 'user_purple',
            theme: _purpleTheme,
          ),
          const SizedBox(height: 20),
          _sectionLabel('Multi Choice', const Color(0xFF4A148C)),
          ChatPollWidget(
            dataSource: _purpleAdapter,
            pollId: 'poll_2',
            userId: 'user_purple',
            theme: _purpleTheme,
          ),
          const SizedBox(height: 20),
          _sectionLabel('Expired', const Color(0xFF4A148C)),
          ChatPollWidget(
            dataSource: _purpleAdapter,
            pollId: 'poll_3',
            userId: 'user_purple',
            theme: _purpleTheme,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }
}
