import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcastsync/bloc/bloc.dart';
import 'package:podcastsync/components/audio.dart';
import 'package:podcastsync/screens/navigation-events.dart';

import '../episode.dart';

class NavigationBloc extends Bloc {
//  StreamSubscription _audioPlayerStateSubscription;
//
//  Stream<String> get example => _exampleSubject.stream;
//
//  Sink<String> get exampleSink => _exampleSubject.sink;
//  final StreamController<String> _exampleSubject = StreamController<String>();

  NavigationBloc() {
    // BEGIN COUNTER STUFF
    _counter = 0;
    // Whenever there is a new event, we want to map it to a new state
    _counterEventController.stream.listen(_handleCounterEvent);
    // END COUNTER STUFF
    _playerController.stream.listen(_handlePlayerEvent);
  }

  // EXPERIMENTAL
  List<Episode> showEpisodeList;

  final _player = AudioPlayer();

  // Not needed currently?
  // final _audioStreamStateController = StreamController<AudioPlayer>.broadcast();
  final _playerController = StreamController<AudioStreamEvent>.broadcast();

  Sink<AudioStreamEvent> get playerEventSink => _playerController.sink;

  Future<void> _handlePlayerEvent(AudioStreamEvent event) async {
    if (event is AudioStreamChangeEvent) {
      if (!AudioService.running) {
        await AudioService.start(
          backgroundTaskEntrypoint: audioPlayerTaskEntrypoint,
          androidNotificationChannelName: 'Podcast Sync',
          notificationColor: 0xFF2196f3,
          androidNotificationIcon: 'mipmap/ic_launcher',
          enableQueue: true,
        );
        await AudioService.skipToNext();
      }

      await AudioService.addQueueItem(event.mediaItem);

      while (AudioService.currentMediaItem != event.mediaItem) {
        await AudioService.skipToNext();
      }
    }
  }

  // END EXPERIMENTAL

  // BEGIN COUNTER STUFF
  int _counter;
  final _counterStateController = StreamController<int>.broadcast();

  StreamSink<int> get inCounter => _counterStateController.sink;

  // For state, exposing only a stream which outputs data
  int get counter => _counter;

  Stream<int> get counterStream => _counterStateController.stream;
  final _counterEventController = StreamController<CounterEvent>.broadcast();

  // For events, exposing only a sink which is an input
  Sink<CounterEvent> get counterEventSink => _counterEventController.sink;

  void _handleCounterEvent(CounterEvent event) {
    if (event is CounterIncrementEvent) _counter++;
    inCounter.add(_counter);
  }

  // END COUNTER STUFF

  void dispose() {
    // _exampleSubject.close();

    // MORE COUNTER STUFF
    _counterStateController.close();
    _counterEventController.close();
    // END MORE COUNTER STUFF

    _playerController.close();
    // _playerStateController.close();

  }
}
