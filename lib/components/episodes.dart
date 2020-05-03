import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:podcastsync/models/episode.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';
import 'package:podcastsync/screens/navigation-events.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        subtitle: Text(subtitle),
        leading: icon,
        onTap: () async {
          _navigationBloc.playerEventSink
              .add(AudioStreamChangeEvent(episode.toMediaItem()));
          SharedPreferences prefs = await SharedPreferences.getInstance();
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
        });

ListView episodeListView(
    /// Navigation bloc which provides audio playback controls
    final NavigationBloc _navigationBloc,

    /// List of episodes that display in the ListView
    final List<Episode> episodes)
{
  return ListView.builder(
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


