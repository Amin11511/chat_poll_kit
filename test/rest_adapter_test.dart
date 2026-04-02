import 'package:chat_poll_kit/chat_poll_kit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late RestPollAdapter adapter;

  final pollJson = {
    'id': 'poll_1',
    'question': 'Test?',
    'options': [
      {'id': 'a', 'text': 'A', 'votes': 5},
      {'id': 'b', 'text': 'B', 'votes': 3},
    ],
    'allowMultipleChoices': false,
    'allowVoteChange': false,
    'createdAt': DateTime.now().toIso8601String(),
  };

  setUp(() {
    mockDio = MockDio();
    adapter = RestPollAdapter(
      dio: mockDio,
      pollingInterval: const Duration(milliseconds: 100),
    );
  });

  group('RestPollAdapter', () {
    test('getPoll fetches poll via GET', () async {
      when(() => mockDio.get('/polls/poll_1')).thenAnswer(
        (_) async => Response(
          data: pollJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/polls/poll_1'),
        ),
      );

      final poll = await adapter.getPoll('poll_1');
      expect(poll.id, 'poll_1');
      expect(poll.question, 'Test?');
      expect(poll.options.length, 2);
    });

    test('watchPoll emits poll via periodic polling', () async {
      when(() => mockDio.get('/polls/poll_1')).thenAnswer(
        (_) async => Response(
          data: pollJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/polls/poll_1'),
        ),
      );

      final stream = adapter.watchPoll('poll_1');
      final first = await stream.first;

      expect(first.id, 'poll_1');
      expect(first.question, 'Test?');
    });

    test('submitVote sends POST request', () async {
      when(() => mockDio.post(
            '/polls/poll_1/votes',
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/polls/poll_1/votes'),
        ),
      );

      await adapter.submitVote(
        pollId: 'poll_1',
        userId: 'user_1',
        optionIds: ['a'],
      );

      verify(() => mockDio.post(
            '/polls/poll_1/votes',
            data: any(named: 'data'),
          )).called(1);
    });

    test('hasUserVoted checks via GET', () async {
      when(() => mockDio.get(
            '/polls/poll_1/votes',
            queryParameters: {'userId': 'user_1'},
          )).thenAnswer(
        (_) async => Response(
          data: [
            {
              'id': 'v1',
              'pollId': 'poll_1',
              'userId': 'user_1',
              'optionIds': ['a'],
              'votedAt': DateTime.now().toIso8601String(),
            }
          ],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/polls/poll_1/votes'),
        ),
      );

      final result = await adapter.hasUserVoted(
        pollId: 'poll_1',
        userId: 'user_1',
      );
      expect(result, isTrue);
    });

    test('hasUserVoted returns false when no votes', () async {
      when(() => mockDio.get(
            '/polls/poll_1/votes',
            queryParameters: {'userId': 'user_1'},
          )).thenAnswer(
        (_) async => Response(
          data: [],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/polls/poll_1/votes'),
        ),
      );

      final result = await adapter.hasUserVoted(
        pollId: 'poll_1',
        userId: 'user_1',
      );
      expect(result, isFalse);
    });

    test('watchPoll stream can be cancelled', () async {
      int callCount = 0;
      when(() => mockDio.get('/polls/poll_1')).thenAnswer(
        (_) async {
          callCount++;
          return Response(
            data: pollJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/polls/poll_1'),
          );
        },
      );

      final stream = adapter.watchPoll('poll_1');
      final sub = stream.listen((_) {});

      // Wait for at least one poll
      await Future<void>.delayed(const Duration(milliseconds: 150));
      await sub.cancel();

      final countAtCancel = callCount;
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // Should not have continued polling after cancel
      expect(callCount, countAtCancel);
    });

    test('watchPoll emits errors from failed requests', () async {
      when(() => mockDio.get('/polls/poll_1'))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/polls/poll_1'),
        message: 'Network error',
      ));

      final stream = adapter.watchPoll('poll_1');
      expect(stream, emitsError(isA<DioException>()));
    });
  });
}
