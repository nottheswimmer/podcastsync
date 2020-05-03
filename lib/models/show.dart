import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:podcastsync/providers/spreaker.dart';

import 'episode.dart';

class InvalidProviderException implements Exception {
  InvalidProviderException(String msg);
}

class Show {
  /// Title of the show
  final String title;

  /// Description of the show
  final String description;

  /// A future which can be awaited to request the episodes of the show
  final Future<List<Episode>> episodes;

  /// The image for the show
  final Image image;

  /// The date of the show's most recent episode
  final DateTime last_episode_at;

  /// The image URI for the show
  final String image_uri;

  // The provider of the show
  final String provider;

  // Metadata that can differ depending on the provider
  final Map<String, dynamic> provider_metadata;

  Show({
    this.title,
    this.description,
    this.episodes,
    this.image,
    this.last_episode_at,
    this.image_uri,
    this.provider,
    this.provider_metadata,
  });

  // To generic JSON for storage
  Map<String, dynamic> toJson() => {
        'title': this.title,
        'description': this.description,
        'last_episode_at': this.last_episode_at.toIso8601String(),
        'image_uri': this.image_uri,
        'provider': this.provider,
        'provider_metadata': this.provider_metadata,
      };

  /// Image cache
  static var images = new HashMap<String, Image>();

  // From generic Storage JSON
  factory Show.fromJson(Map<String, dynamic> json) {
    String image_uri = json['image_uri'];
    Image image;

    // Check if we've seen this image before
    if (images.containsKey(image_uri)) {
      image = images[image_uri];
    } else {
      // If not, load it from the web
      image = Image.network(image_uri);
      images.putIfAbsent(image_uri, () => image);
    }

    Future<List<Episode>> episodes;

    if (json['provider'] == 'spreaker') {
      episodes = searchSpreakerEpisodesByShow(
          json['provider_metadata']['show_id'], json['title']);
    } else {
      throw new InvalidProviderException("Invalid provider");
    }

    return Show(
        title: json['title'],
        image_uri: image_uri,
        image: image,
        // TODO: Update this value when retrieved from JSON?
        last_episode_at: DateTime.parse(json['last_episode_at']),
        provider: json['provider'],
        provider_metadata: json['provider_metadata'],
        episodes: episodes);
  }

  factory Show.fromSpreakerJson(Map<String, dynamic> json) {
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
    return Show(
        title: json['title'],
        episodes: searchSpreakerEpisodesByShow(json['show_id'], json['title']),
        image_uri: image_url,
        image: image,
        last_episode_at: DateTime.parse(json['last_episode_at']),
        provider: 'spreaker',
        provider_metadata: {'show_id': json['show_id']});
  }
}
