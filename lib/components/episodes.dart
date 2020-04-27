import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:podcastsync/models/episode.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';
import 'package:podcastsync/screens/navigation-events.dart';

ListTile episodeTile(NavigationBloc _navigationBloc, String title,
    String subtitle, Image icon, MediaItem mediaItem) =>
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

ListView episodeListView(NavigationBloc _navigationBloc, List<Episode> data) {
  return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return episodeTile(_navigationBloc, data[index].title,
            data[index].show, data[index].image, data[index].toMediaItem());
      });
}
