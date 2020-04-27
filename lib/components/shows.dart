import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podcastsync/bloc/bloc-prov.dart';
import 'package:podcastsync/components/episodes.dart';
import 'package:podcastsync/models/episode.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';
import 'package:podcastsync/screens/pages/search.dart';

Widget showTile(
    NavigationBloc _navigationBloc,
    String title,
    String subtitle,
    Image icon,
    Future<List<Episode>> episodes,
    BuildContext context) =>
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
                      ))));
        });
