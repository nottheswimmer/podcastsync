import 'dart:collection';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class Episode {
  /// Title of the episode
  final String title;

  /// Duration, in milliseconds
  final int duration;

  /// Image for the episode
  final Image image;

  /// Image URL for the episode (for background service playback)
  final String image_uri;

  /// Date the episode was published
  final DateTime published;

  /// Title of the show the episode belongs to
  final String show;

  /// Audio download URL for the episode
  final String download_url;

  Episode(
      {this.title,
      this.duration,
      this.image,
      this.published,
      this.show,
      this.download_url,
      this.image_uri});

  // Image cache
  static var images = new HashMap<String, Image>();

  factory Episode.fromSpreakerJson(Map<String, dynamic> json) {
    String image_url = json['image_url'];
    Image image;

    // Check if we've seen this image before
    if (images.containsKey(image_url)) {
      image = images[image_url];
    } else {
      // If not, load it from the web
      image = Image.network(image_url);
      images.putIfAbsent(image_url, () => image);
    }
    return Episode(
      title: json['title'],
      duration: json['duration'],
      image_uri: image_url,
      image: image,
      published: DateTime.parse(json['published_at']),
      show: json['show']['title'],
      download_url: json['download_url'],
    );
  }

  MediaItem toMediaItem() {
    return MediaItem(
      id: this.download_url,
      album: this.show,
      title: this.title,
      artUri: this.image_uri,
      duration: this.duration,
    );
  }
}
