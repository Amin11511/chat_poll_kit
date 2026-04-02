## 1.0.1

* Add screenshots to README (Light, Dark, Green, Purple themes)
* Update example app with 4 themed demo pages

## 1.0.0

* Initial release
* Immutable models: PollModel, PollOption, VoteModel with copyWith and JSON serialization
* Abstract PollDataSource interface with Firebase and REST/Dio adapters
* PollController with ChangeNotifier, optimistic updates, and error handling
* PollValidator for expiry, choice, and duplicate vote checks
* ExpiryTimer with Stream<Duration> countdown
* Full widget set: ChatPollWidget, PollHeader, PollFooter, PollProgressBar, PollOptionTile
* State widgets: PollLoading, PollError, PollExpired
* Deep theming via PollTheme (ThemeExtension) with light/dark defaults
* Animated progress bars using TweenAnimationBuilder
* RTL support with directional-aware layout
* Multi-choice and vote-change support
