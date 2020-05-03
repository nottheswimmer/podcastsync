import 'package:audio_service/audio_service.dart';

// Generic event that can be sent to audio streams
abstract class AudioStreamEvent {}

// Event for changing the current media
class AudioStreamChangeEvent extends AudioStreamEvent {
  MediaItem mediaItem;

  AudioStreamChangeEvent(
    /// The media item this event is telling the player to change to
    final MediaItem mediaItem,
  ) {
    this.mediaItem = mediaItem;
  }
}
