import 'package:flutter/material.dart';

import '../adapters/poll_data_source.dart';
import '../controllers/poll_controller.dart';
import '../theme/poll_theme.dart';
import 'poll_footer.dart';
import 'poll_header.dart';
import 'poll_option_tile.dart';
import 'poll_states/poll_error.dart';
import 'poll_states/poll_expired.dart';
import 'poll_states/poll_loading.dart';

class ChatPollWidget extends StatefulWidget {
  final PollDataSource dataSource;
  final String pollId;
  final String userId;
  final PollTheme? theme;

  final Widget Function(PollTheme theme)? loadingBuilder;
  final Widget Function(String message, PollTheme theme, VoidCallback retry)?
      errorBuilder;
  final Widget Function(PollController controller, PollTheme theme)?
      expiredBuilder;
  final ValueChanged<List<String>>? onVoted;
  final VoidCallback? onExpired;

  const ChatPollWidget({
    super.key,
    required this.dataSource,
    required this.pollId,
    required this.userId,
    this.theme,
    this.loadingBuilder,
    this.errorBuilder,
    this.expiredBuilder,
    this.onVoted,
    this.onExpired,
  });

  @override
  State<ChatPollWidget> createState() => _ChatPollWidgetState();
}

class _ChatPollWidgetState extends State<ChatPollWidget> {
  late PollController _controller;
  late PollTheme _theme;
  bool _previousExpiredState = false;

  @override
  void initState() {
    super.initState();
    _theme = widget.theme ?? PollTheme.light();
    _controller = PollController(
      dataSource: widget.dataSource,
      pollId: widget.pollId,
      userId: widget.userId,
    );
    _controller.addListener(_onControllerChanged);
    _controller.initialize();
  }

  @override
  void didUpdateWidget(ChatPollWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme != null) {
      _theme = widget.theme!;
    }
    if (oldWidget.pollId != widget.pollId ||
        oldWidget.userId != widget.userId) {
      _controller.removeListener(_onControllerChanged);
      _controller.dispose();
      _controller = PollController(
        dataSource: widget.dataSource,
        pollId: widget.pollId,
        userId: widget.userId,
      );
      _controller.addListener(_onControllerChanged);
      _controller.initialize();
    }
  }

  void _onControllerChanged() {
    if (_controller.isExpired && !_previousExpiredState) {
      _previousExpiredState = true;
      widget.onExpired?.call();
    }
    _previousExpiredState = _controller.isExpired;
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: _theme.backgroundColor,
            borderRadius: _theme.containerBorderRadius,
          ),
          padding: _theme.containerPadding,
          child: _buildContent(),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_controller.isLoading && _controller.poll == null) {
      return widget.loadingBuilder?.call(_theme) ??
          PollLoading(theme: _theme);
    }

    if (_controller.errorMessage != null && _controller.poll == null) {
      return widget.errorBuilder?.call(
            _controller.errorMessage!,
            _theme,
            () => _controller.initialize(),
          ) ??
          PollError(
            message: _controller.errorMessage!,
            theme: _theme,
            onRetry: () => _controller.initialize(),
          );
    }

    final poll = _controller.poll;
    if (poll == null) return const SizedBox.shrink();

    if (_controller.isExpired) {
      return widget.expiredBuilder?.call(_controller, _theme) ??
          PollExpired(
            poll: poll,
            selectedOptionIds: _controller.selectedOptionIds,
            theme: _theme,
          );
    }

    final showResults = _controller.hasVoted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        PollHeader(
          question: poll.question,
          expiresAt: poll.expiresAt,
          theme: _theme,
        ),
        SizedBox(height: _theme.optionSpacing * 1.5),
        ...poll.options.map(
          (option) => Padding(
            padding: EdgeInsets.only(bottom: _theme.optionSpacing),
            child: PollOptionTile(
              option: option,
              totalVotes: poll.totalVotes,
              isSelected:
                  _controller.selectedOptionIds.contains(option.id),
              showResults: showResults,
              enabled: !_controller.hasVoted ||
                  (poll.allowVoteChange),
              theme: _theme,
              onTap: () => _controller.toggleOption(option.id),
            ),
          ),
        ),
        if (_controller.errorMessage != null) ...[
          const SizedBox(height: 4),
          Text(
            _controller.errorMessage!,
            style: _theme.optionTextStyle?.copyWith(
              color: _theme.errorColor,
              fontSize: 12,
            ),
          ),
        ],
        SizedBox(height: _theme.optionSpacing / 2),
        PollFooter(
          totalVotes: poll.totalVotes,
          hasVoted: _controller.hasVoted,
          isExpired: false,
          theme: _theme,
          onVote: _controller.selectedOptionIds.isNotEmpty
              ? () async {
                  await _controller.vote();
                  if (_controller.hasVoted && _controller.errorMessage == null) {
                    widget.onVoted
                        ?.call(_controller.selectedOptionIds.toList());
                  }
                }
              : null,
        ),
      ],
    );
  }
}
