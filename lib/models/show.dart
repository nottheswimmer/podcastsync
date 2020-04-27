import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:podcastsync/providers/spreaker.dart';

import 'episode.dart';


class Show {
  final String title;
  final String description;
  final Future<List<Episode>> episodes;
  final Image image;
  final DateTime last_episode_at;
  final String image_uri;

  Show(
      {this.title,
        this.description,
        this.episodes,
        this.image,
        this.last_episode_at,
        this.image_uri});

  // Image cache
  static var images = new HashMap<String, Image>();

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
    );
  }
}
