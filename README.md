# chat_poll_kit

A complete poll system for Flutter chat applications — with state management, real-time sync, backend abstraction (Firebase + REST/Dio), deep theming, and animated UI.

## Screenshots

| Light Theme | Dark Theme |
|:-----------:|:----------:|
| ![Light](https://raw.githubusercontent.com/Amin11511/chat_poll_kit/main/screenshots/1_light_theme.png) | ![Dark](https://raw.githubusercontent.com/Amin11511/chat_poll_kit/main/screenshots/2_dark_theme.png) |

## Features

- **Immutable models** — `PollModel`, `PollOption`, `VoteModel` with `copyWith` and JSON serialization
- **Backend abstraction** — swap between Firebase Firestore and REST/Dio with a single interface
- **Real-time sync** — Firestore snapshots or REST polling (`Timer.periodic`, configurable interval)
- **Atomic votes** — Firestore `runTransaction` for safe vote increments
- **Optimistic updates** — instant UI feedback with automatic rollback on failure
- **Animated progress bars** — smooth `TweenAnimationBuilder` transitions
- **Expiry countdown** — live `Stream<Duration>` timer with auto-completion
- **Deep theming** — `PollTheme` with light/dark defaults and full `ThemeExtension` support
- **RTL support** — directional-aware padding and alignment
- **Multi/single choice** — configurable per poll
- **Vote change** — optional re-voting support
- **Custom state widgets** — override loading, error, and expired states
- **Zero external state management** — `ChangeNotifier` + `ListenableBuilder`

## Getting Started

```yaml
dependencies:
  chat_poll_kit: ^1.0.0
```

For Firebase support, also add:
```yaml
dependencies:
  cloud_firestore: ^5.6.0
  firebase_core: ^3.12.0
```

## Usage

### Basic (REST adapter)

```dart
import 'package:chat_poll_kit/chat_poll_kit.dart';
import 'package:dio/dio.dart';

final adapter = RestPollAdapter(
  dio: Dio(BaseOptions(baseUrl: 'https://api.example.com')),
  baseEndpoint: '/api/polls',
  pollingInterval: Duration(seconds: 5),
);

ChatPollWidget(
  dataSource: adapter,
  pollId: 'poll_123',
  userId: 'user_456',
  theme: PollTheme.light(),
  onVoted: (optionIds) => print('Voted: $optionIds'),
);
```

### Firebase adapter

```dart
final adapter = FirebasePollAdapter(
  firestore: FirebaseFirestore.instance,
  pollsCollection: 'polls',
  votesCollection: 'votes',
);

ChatPollWidget(
  dataSource: adapter,
  pollId: 'poll_123',
  userId: FirebaseAuth.instance.currentUser!.uid,
);
```

### Custom theme

```dart
ChatPollWidget(
  dataSource: adapter,
  pollId: 'poll_123',
  userId: 'user_456',
  theme: PollTheme.dark().copyWith(
    progressBarColor: Colors.amber,
    containerBorderRadius: BorderRadius.circular(16),
  ),
);
```

### Custom state builders

```dart
ChatPollWidget(
  dataSource: adapter,
  pollId: 'poll_123',
  userId: 'user_456',
  loadingBuilder: (theme) => MyCustomLoader(),
  errorBuilder: (message, theme, retry) => MyCustomError(message, retry),
  expiredBuilder: (controller, theme) => MyExpiredView(controller),
);
```

## Architecture

```
lib/
  chat_poll_kit.dart          # barrel export
  src/
    models/
      poll_option.dart        # immutable option with percentage()
      poll_model.dart         # immutable poll with isExpired, totalVotes
      vote_model.dart         # immutable vote record
    adapters/
      poll_data_source.dart   # abstract interface
      firebase_adapter.dart   # Firestore + transactions
      rest_adapter.dart       # Dio + Timer.periodic polling
    controllers/
      poll_controller.dart    # ChangeNotifier with optimistic updates
    utils/
      poll_validator.dart     # expiry, choice, duplicate vote checks
      expiry_timer.dart       # Stream<Duration> countdown
    theme/
      poll_theme.dart         # ThemeExtension with full lerp
      poll_theme_defaults.dart
    widgets/
      chat_poll_widget.dart   # main public widget
      poll_header.dart        # question + countdown
      poll_footer.dart        # total votes + vote button
      poll_progress_bar.dart  # animated bar
      poll_option_tile.dart   # option row
      poll_states/
        poll_loading.dart
        poll_error.dart
        poll_expired.dart
```

## REST API Contract

The `RestPollAdapter` expects these endpoints:

| Method | Path | Description |
|--------|------|-------------|
| GET | `/{pollId}` | Returns poll JSON |
| POST | `/{pollId}/votes` | Submit a vote |
| GET | `/{pollId}/votes?userId={id}` | Get user's votes |

## License

MIT
