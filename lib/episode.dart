import 'dart:collection';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String API_SPREAKER_HOST = 'api.spreaker.com';
const String API_SPREAKER_SEARCH = '/v2/search';

class Episode {
  final String title;
  final int duration; // in ms
  final Image image;
  final String image_uri;
  final DateTime published;
  final String show;
  final String download_url;

  Episode({
    this.title, this.duration, this.image, this.published, this.show,
    this.download_url, this.image_uri
  });

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

Future<List<Episode>> searchSpreakerEpisodes(String searchTerm) async {
  final uri = Uri.https(API_SPREAKER_HOST, API_SPREAKER_SEARCH,
      {'type': 'episodes', 'q': searchTerm});
  print(uri);
  print('Hello world!');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    var episodes = new List<Episode>();
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> jsonItems = jsonResponse["response"]["items"];
    for (Map<String, dynamic> item in jsonItems) {
      episodes.add(new Episode.fromSpreakerJson(item));
    }
    return episodes;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load spreaker episodes');
  }
}