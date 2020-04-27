import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podcastsync/bloc/bloc-prov.dart';
import 'package:podcastsync/components/audio.dart';
import 'package:podcastsync/components/episodes.dart';
import 'package:podcastsync/models/episode.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';

Widget showTile(
    /// Navigation bloc which provides audio playback controls
    final NavigationBloc _navigationBloc,

    /// The text to display in the show's title area
    final String title,

    /// The text to display in the show's subtitle area
    final String subtitle,

    /// The icon to display next to the show
    final Image icon,

    /// A future which can be awaited to request the episodes of the show
    final Future<List<Episode>> episodes,

    /// Build context to pass to the show episodes popup
    final BuildContext context) =>
    ListTile(
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text(subtitle),
        leading: icon,
        onTap: () async {
          return Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BlocProvider(
                      bloc: _navigationBloc,
                      child: Scaffold(
                        body: SizedBox(
                            child: FutureBuilder<List<Episode>>(
                                future: episodes,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<Episode> data = snapshot.data;
                                    return episodeListView(
                                        _navigationBloc, data);
                                  } else if (snapshot.hasError) {
                                    return Text("${snapshot.error}");
                                  }
                                  // By default, show a loading spinner.
                                  return CircularProgressIndicator();
                                })),
                        floatingActionButton: FloatingActionButton(
                          child: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        persistentFooterButtons: <Widget>[
                          MediaPlayer(),
                        ],
                      ))));
        });
