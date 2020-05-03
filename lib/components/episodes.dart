import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:podcastsync/components/shows.dart';
import 'package:podcastsync/models/episode.dart';
import 'package:podcastsync/models/show.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';
import 'package:podcastsync/screens/navigation-events.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

ListTile episodeTile(
    /// Navigation bloc which provides audio playback controls
    final NavigationBloc _navigationBloc,

    /// The text to display in the episode's title area
    final String title,

    /// The text to display in the episode's subtitle area
    final String subtitle,

    /// The icon to display next to the episode
    final Image icon,

    /// The media item to provide to the audio playback service on tap
    final Episode episode) =>
    ListTile(
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text("Uploaded ${timeago.format(episode.published)}"),
        leading: icon,
        onTap: () async {
          _navigationBloc.playerEventSink
              .add(AudioStreamChangeEvent(episode.toMediaItem()));
          await addEpisodeToRecentlyPlayed(episode);
        }

        );

Future addEpisodeToRecentlyPlayed(Episode episode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Store the thing being played in the play history
  if (prefs.containsKey('recentlyPlayed')) {
    List<String> recentlyPlayed = prefs.getStringList('recentlyPlayed');
    // Remove instances of the recent episode from the recently played list
    recentlyPlayed.removeWhere((jsonEpisode) {
      Map<String, dynamic> decoded = jsonDecode(jsonEpisode);
      return decoded['download_url'] == episode.download_url;
    });
    // Add this item to the recently played list
    recentlyPlayed.add(jsonEncode(episode.toJson()));
    prefs.setStringList('recentlyPlayed', recentlyPlayed);
  } else {
    // If the key doesn't exist, make it.
    prefs.setStringList('recentlyPlayed', [jsonEncode(episode.toJson())]);
  }
}

ListView episodeListView(
    /// Navigation bloc which provides audio playback controls
    final NavigationBloc _navigationBloc,

    /// List of episodes that display in the ListView
    final List<Episode> episodes,
    final PageStorageKey key,
    )
{
  return ListView.builder(
      key: key,
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        return episodeTile(_navigationBloc, episodes[index].title,
            episodes[index].show, episodes[index].image, episodes[index]);
      });
}

ListView episodeListViewWithHeader(
    /// Navigation bloc which provides audio playback controls
    final NavigationBloc _navigationBloc,

    /// List of episodes that display in the ListView
    final List<Episode> episodes,

    final String header)
{
  return ListView.builder(
      key: PageStorageKey(header),
      itemCount: episodes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // return the header
          return Padding(
            padding: const EdgeInsets.only(left: 15, top: 10),
            child: Text(header, style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black54
            ),),
          );
        }
        index -= 1;

        return episodeTile(_navigationBloc, episodes[index].title,
            episodes[index].show, episodes[index].image, episodes[index]);
      });
}

Future<List<Episode>> getRecentlyPlayed() async {
  var prefs = await SharedPreferences.getInstance();
  List<String> episodeStringList = prefs.containsKey('recentlyPlayed')
      ? prefs.getStringList('recentlyPlayed')
      : [];

  List<dynamic> episodeJsonList =
  episodeStringList.map((e) => jsonDecode(e)).toList(growable: false);
  List<Episode> episodeList =
  episodeJsonList.map((e) => Episode.fromJson(e)).toList();
  return episodeList.reversed.toList();
}

Future<List<Episode>> getLatestFromSubscriptions() async {
  print('getLatestFromSubscriptions');
  List<Show> subscriptions = await getSubscriptions();
  List<Episode> latest = [];
  for (Show show in subscriptions) {
    print('adding episodes from a show');
    latest.addAll(await show.episodes);
  }
  latest.sort((a, b) => a.published.isBefore(b.published) ? 1 : -1);
  return latest;

}
