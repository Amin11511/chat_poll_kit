import 'dart:async';

import 'package:chat_poll_kit/chat_poll_kit.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Mock adapter
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
      if (poll != null && !controller.isClosed) controller.add(poll);
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
        if (optionIds.contains(o.id)) return o.copyWith(votes: o.votes + 1);
        return o;
      }).toList(),
    );
    _polls[pollId] = updated;
    _votes[pollId] = [
      ...(_votes[pollId] ?? []),
      VoteModel(
        id: 'vote_${DateTime.now().millisecondsSinceEpoch}',
        pollId: pollId,
        userId: userId,
        optionIds: optionIds,
        votedAt: DateTime.now(),
      ),
    ];
    _controllers[pollId]?.add(updated);
  }

  @override
  Future<bool> hasUserVoted({
    required String pollId,
    required String userId,
  }) async {
    return (_votes[pollId] ?? []).any((v) => v.userId == userId);
  }

  @override
  Future<List<VoteModel>> getUserVotes({
    required String pollId,
    required String userId,
  }) async {
    return (_votes[pollId] ?? []).where((v) => v.userId == userId).toList();
  }
}

// ---------------------------------------------------------------------------
// Chat message model
// ---------------------------------------------------------------------------
enum MessageType { text, poll }
enum MessageSender { me, other }

class ChatMessage {
  final String id;
  final MessageType type;
  final MessageSender sender;
  final String senderName;
  final String? text;
  final String? pollId;
  final String time;

  const ChatMessage({
    required this.id,
    required this.type,
    required this.sender,
    required this.senderName,
    this.text,
    this.pollId,
    required this.time,
  });
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------
final _poll1 = PollModel(
  id: 'poll_1',
  question: 'What should we use for the backend?',
  options: const [
    PollOption(id: 'a', text: 'Node.js', votes: 12),
    PollOption(id: 'b', text: 'Go', votes: 8),
    PollOption(id: 'c', text: 'Python (Django)', votes: 15),
    PollOption(id: 'd', text: 'Dart (Shelf)', votes: 5),
  ],
  createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
  expiresAt: DateTime.now().add(const Duration(hours: 2)),
);

final _poll2 = PollModel(
  id: 'poll_2',
  question: 'When should we schedule the sprint review?',
  options: const [
    PollOption(id: 'mon', text: 'Monday 10 AM', votes: 6),
    PollOption(id: 'wed', text: 'Wednesday 2 PM', votes: 9),
    PollOption(id: 'fri', text: 'Friday 11 AM', votes: 4),
  ],
  createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  expiresAt: DateTime.now().subtract(const Duration(minutes: 10)),
);

final _chatMessages = <ChatMessage>[
  const ChatMessage(
    id: 'm1',
    type: MessageType.text,
    sender: MessageSender.other,
    senderName: 'Ahmed',
    text: 'Hey team! We need to decide on the tech stack for the new project.',
    time: '10:30 AM',
  ),
  const ChatMessage(
    id: 'm2',
    type: MessageType.text,
    sender: MessageSender.me,
    senderName: 'You',
    text: 'Good idea! Let\'s create a poll so everyone can vote.',
    time: '10:31 AM',
  ),
  const ChatMessage(
    id: 'm3',
    type: MessageType.poll,
    sender: MessageSender.other,
    senderName: 'Ahmed',
    pollId: 'poll_1',
    time: '10:32 AM',
  ),
  const ChatMessage(
    id: 'm4',
    type: MessageType.text,
    sender: MessageSender.me,
    senderName: 'You',
    text: 'Great poll! I\'ll vote now 👍',
    time: '10:33 AM',
  ),
  const ChatMessage(
    id: 'm5',
    type: MessageType.text,
    sender: MessageSender.other,
    senderName: 'Sara',
    text: 'Also, here\'s the expired poll from last week about the sprint review:',
    time: '10:35 AM',
  ),
  const ChatMessage(
    id: 'm6',
    type: MessageType.poll,
    sender: MessageSender.other,
    senderName: 'Sara',
    pollId: 'poll_2',
    time: '10:35 AM',
  ),
  const ChatMessage(
    id: 'm7',
    type: MessageType.text,
    sender: MessageSender.other,
    senderName: 'Ahmed',
    text: 'Wednesday won! See you all at 2 PM 🎉',
    time: '10:36 AM',
  ),
];

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
  bool _isDark = false;

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
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: ChatScreen(
        isDark: _isDark,
        onToggleTheme: () => setState(() => _isDark = !_isDark),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat Screen
// ---------------------------------------------------------------------------
class ChatScreen extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  ChatScreen({super.key, required this.isDark, required this.onToggleTheme});

  late final _adapter = MockPollAdapter([_poll1, _poll2]);

  @override
  Widget build(BuildContext context) {
    final pollTheme = isDark ? PollTheme.dark() : PollTheme.light();
    final bgColor = isDark ? const Color(0xFF0B141A) : const Color(0xFFECE5DD);

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Color(0xFF25D366),
            child: Icon(Icons.group, color: Colors.white, size: 20),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dev Team', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('Ahmed, Sara, You', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: Container(
        color: bgColor,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = _chatMessages[index];
                  return _buildMessage(context, msg, pollTheme);
                },
              ),
            ),
            _buildInputBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, ChatMessage msg, PollTheme pollTheme) {
    final isMe = msg.sender == MessageSender.me;
    final bubbleColor = isMe
        ? (isDark ? const Color(0xFF005C4B) : const Color(0xFFDCF8C6))
        : (isDark ? const Color(0xFF1F2C34) : Colors.white);
    final textColor = isDark ? Colors.white : Colors.black87;
    final nameColor = isMe
        ? const Color(0xFF075E54)
        : const Color(0xFF6C63FF);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: nameColor.withValues(alpha: 0.2),
              child: Text(
                msg.senderName[0],
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: nameColor),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              decoration: BoxDecoration(
                color: msg.type == MessageType.poll ? Colors.transparent : bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isMe ? 12 : 2),
                  bottomRight: Radius.circular(isMe ? 2 : 12),
                ),
              ),
              child: msg.type == MessageType.poll
                  ? _buildPollBubble(msg, pollTheme, isMe)
                  : _buildTextBubble(msg, textColor, nameColor, isMe),
            ),
          ),
          if (isMe) const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildTextBubble(
      ChatMessage msg, Color textColor, Color nameColor, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                msg.senderName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: nameColor,
                ),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  msg.text!,
                  style: TextStyle(fontSize: 15, color: textColor),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                msg.time,
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withValues(alpha: 0.5),
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 2),
                Icon(Icons.done_all, size: 14,
                    color: isDark ? const Color(0xFF53BDEB) : const Color(0xFF4FC3F7)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollBubble(ChatMessage msg, PollTheme pollTheme, bool isMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChatPollWidget(
          dataSource: _adapter,
          pollId: msg.pollId!,
          userId: 'user_me',
          theme: pollTheme.copyWith(
            containerBorderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isMe ? 12 : 2),
              bottomRight: Radius.circular(isMe ? 2 : 12),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12, bottom: 4, top: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              Text(
                msg.time,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF1F2C34) : Colors.white,
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A3942) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_emotions_outlined, color: Colors.grey[500], size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  Icon(Icons.attach_file, color: Colors.grey[500], size: 22),
                  const SizedBox(width: 8),
                  Icon(Icons.camera_alt, color: Colors.grey[500], size: 22),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF00A884),
            child: const Icon(Icons.mic, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}
