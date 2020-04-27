import 'dart:convert';

import 'package:podcastsync/models/episode.dart';
import 'package:http/http.dart' as http;
import 'package:podcastsync/models/show.dart';

const String API_SPREAKER_HOST = 'api.spreaker.com';
const String API_SPREAKER_SEARCH = '/v2/search';
const String API_SPREAKER_SHOWS = '/v2/shows';

Future<List<Episode>> searchSpreakerEpisodes(String searchTerm) async {
  final uri = Uri.https(API_SPREAKER_HOST, API_SPREAKER_SEARCH,
      {'type': 'episodes', 'q': searchTerm});
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
    throw Exception('Failed to load spreaker episodes from $uri');
  }
}

Future<List<Episode>> searchSpreakerEpisodesByShow(
    int showId, String showTitle) async {
  final uri =
      Uri.https(API_SPREAKER_HOST, '$API_SPREAKER_SHOWS/$showId/episodes');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    var episodes = new List<Episode>();
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> jsonItems = jsonResponse["response"]["items"];
    for (Map<String, dynamic> item in jsonItems) {
      item['show'] = {};
      item['show']['title'] = showTitle;
      episodes.add(new Episode.fromSpreakerJson(item));
    }
    return episodes;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load spreaker episodes from $uri');
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
