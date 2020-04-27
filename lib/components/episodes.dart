import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:podcastsync/models/episode.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';
import 'package:podcastsync/screens/navigation-events.dart';

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
    final MediaItem mediaItem) =>
    ListTile(
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text(subtitle),
        leading: icon,
        onTap: () => _navigationBloc.playerEventSink
            .add(AudioStreamChangeEvent(mediaItem)));

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
            episodes[index].show, episodes[index].image, episodes[index].toMediaItem());
      });
}
