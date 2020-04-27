import 'dart:collection';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'episode.dart';

const String API_SPREAKER_HOST = 'api.spreaker.com';
const String API_SPREAKER_SEARCH = '/v2/search';


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

Future<List<Show>> searchSpreakerShows(String searchTerm) async {
  final uri = Uri.https(API_SPREAKER_HOST, API_SPREAKER_SEARCH,
      {'type': 'shows', 'q': searchTerm});
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    var shows = new List<Show>();
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> jsonItems = jsonResponse["response"]["items"];
    for (Map<String, dynamic> item in jsonItems) {
      shows.add(new Show.fromSpreakerJson(item));
    }
    return shows;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load spreaker shows');
  }
}