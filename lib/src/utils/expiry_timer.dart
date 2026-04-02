import 'dart:async';

class ExpiryTimer {
  static Stream<Duration> countdown(DateTime expiresAt) {
    late StreamController<Duration> controller;
    Timer? timer;

    controller = StreamController<Duration>(
      onListen: () {
        void tick() {
          final remaining = expiresAt.difference(DateTime.now());
          if (remaining.isNegative || remaining == Duration.zero) {
            controller.add(Duration.zero);
            timer?.cancel();
            controller.close();
          } else {
            controller.add(remaining);
          }
        }

        tick();
        timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
      },
      onCancel: () {
        timer?.cancel();
      },
    );

    return controller.stream;
  }

  static String formatDuration(Duration duration) {
    if (duration == Duration.zero) return 'Expired';

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (days > 0) return '${days}d ${hours}h remaining';
    if (hours > 0) return '${hours}h ${minutes}m remaining';
    if (minutes > 0) return '${minutes}m ${seconds}s remaining';
    return '${seconds}s remaining';
  }
}
