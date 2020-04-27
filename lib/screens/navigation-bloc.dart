import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:podcastsync/bloc/bloc.dart';
import 'package:podcastsync/components/audio.dart';
import 'package:podcastsync/screens/navigation-events.dart';

class NavigationBloc extends Bloc {
  NavigationBloc() {
    _counter = 0; // TODO: Remove demo code
    // Whenever there is a new event, we want to map it to a new state
    _counterEventController.stream
        .listen(_handleCounterEvent); // TODO: Remove demo code

    // Stream events sent to the player controller to the _handlePlayerEvent
    //  function
    _playerController.stream.listen(_handlePlayerEvent);
  }

  // Used by this module to control audio stream
  final _playerController = StreamController<AudioStreamEvent>.broadcast();

  // Sink exposed to pages via the navigationBloc to update the current media
  Sink<AudioStreamEvent> get playerEventSink => _playerController.sink;

  /// Handle events sent to the playerEventSink
  Future<void> _handlePlayerEvent(
      /// Event sent to the playerEventSink
      final AudioStreamEvent event
      ) async {

    // If the event is an audio change event (others could be supported)...
    if (event is AudioStreamChangeEvent) {
      // If the service isn't running...
      if (!AudioService.running) {
        // start it and skip once (the service will start with no media running
        //   and one skip is a hack to fix a bug where the media won't play
        //   right away)
        await AudioService.start(
          backgroundTaskEntrypoint: audioPlayerTaskEntrypoint,
          androidNotificationChannelName: 'Podcast Sync',
          notificationColor: 0xFF2196f3,
          androidNotificationIcon: 'mipmap/ic_launcher',
          enableQueue: true,
        );
        await AudioService.skipToNext();
      }

      // Add the media item from the audio change event
      await AudioService.addQueueItem(event.mediaItem);

      // Skip forward until the media item is the current item.
      // TODO: Ensure no bug could cause an infinite loop here?
      while (AudioService.currentMediaItem != event.mediaItem) {
        await AudioService.skipToNext();
      }
    }
  }

  // TODO: Remove demo code below
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

  // TODO: Remove demo code above

  void dispose() {
    _counterStateController.close(); // TODO: Remove demo code
    _counterEventController.close(); // TODO: Remove demo code

    _playerController.close();
    // _playerStateController.close();
  }
}
