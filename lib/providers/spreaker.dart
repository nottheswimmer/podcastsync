import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:podcastsync/models/episode.dart';
import 'package:http/http.dart' as http;
import 'package:podcastsync/models/show.dart';

const String API_SPREAKER_HOST = 'api.spreaker.com';
const String API_SPREAKER_SEARCH = '/v2/search';
const String API_SPREAKER_SHOWS = '/v2/shows';

// TODO: Populate via service rather than hardcoding filters
const List<String> FILTERED_SHOWS = [
  'The Greatest Sounds of Sex',
  'Best XXX and Porn Sounds of All Time',
  'The Sounds of Pornography and Sex',
  'XXX Sex Sounds With Your Mom',
  'Eclectically Sexual Sounds',
  'The Sounds of Passionate Sex (NSFW ASMR)',
];

Future<List<Episode>> searchSpreakerEpisodes(
  /// Search term input by user used to search for episodes
  final String searchTerm,
) async {
  final uri = Uri.https(API_SPREAKER_HOST, API_SPREAKER_SEARCH,
      {'type': 'episodes', 'q': searchTerm});
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    var episodes = new List<Episode>();
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> jsonItems = jsonResponse["response"]["items"];
    for (Map<String, dynamic> item in jsonItems) {
      try {
        if (FILTERED_SHOWS.contains(item["show"]["title"])) {
          continue;
        }
        episodes.add(new Episode.fromSpreakerJson(item));
      } catch (exception, stackTrace) {
        log('Could not parse episode $item due to $exception',
            stackTrace: stackTrace);
      }
      ;
    }
    return episodes;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load spreaker episodes from $uri');
  }
}

Future<List<Episode>> searchSpreakerEpisodesByShow(
  /// Spreaker show ID used to look up show episodes
  final int showId,

  /// Show episode title used to build episode item
  final String showTitle,
) async {
  final uri =
      Uri.https(API_SPREAKER_HOST, '$API_SPREAKER_SHOWS/$showId/episodes');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    var episodes = new List<Episode>();
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> jsonItems = jsonResponse["response"]["items"];
    for (Map<String, dynamic> item in jsonItems) {
      try {
        item['show'] = {};
        item['show']['title'] = showTitle;
        episodes.add(new Episode.fromSpreakerJson(item));
      } catch (exception, stackTrace) {
        log('Could not parse episode $item due to $exception',
            stackTrace: stackTrace);
      }
    }
    return episodes;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load spreaker episodes from $uri');
  }
}

Future<List<Show>> searchSpreakerShows(
  /// Search term input by user used to search for shows
  final String searchTerm,
) async {
  // build uri of the spreaker API to query for shows
  final uri = Uri.https(API_SPREAKER_HOST, API_SPREAKER_SEARCH,
      {'type': 'shows', 'q': searchTerm});

  // Get response from spreaker API containing shows
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    var shows = new List<Show>();
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    List<dynamic> jsonItems = jsonResponse["response"]["items"];
    for (Map<String, dynamic> item in jsonItems) {
      try {
        if (FILTERED_SHOWS.contains(item['title'])) continue;
        shows.add(new Show.fromSpreakerJson(item));
      } catch (exception, stackTrace) {
        log('Could not parse show $item due to $exception',
            stackTrace: stackTrace);
      }
    }
    return shows;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load spreaker shows');
  }
}
