import 'package:audio_service/audio_service.dart';

abstract class CounterEvent {}

class CounterIncrementEvent extends CounterEvent {}

abstract class AudioStreamEvent {}

class AudioStreamChangeEvent extends AudioStreamEvent {
  MediaItem mediaItem;
  AudioStreamChangeEvent(MediaItem mediaItem) {
    this.mediaItem = mediaItem;
  }
}