import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podcastsync/bloc/bloc-prov.dart';
import 'package:podcastsync/components/episodes.dart';
import 'package:podcastsync/models/episode.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NavigationBloc _navigationBloc = BlocProvider.of(context);
    return recentlyPlayedWidget(navigationBloc: _navigationBloc);
  }
}

// Displays one Entry. If the entry has children then it's displayed
// with an ExpansionTile.
class EntryItem extends StatelessWidget {
  // The entire multilevel list displayed by this app.

  EntryItem(this.entry);

  final Entry entry;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) return ListTile(title: root.widget);
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: root.widget,
      initiallyExpanded: root.initiallyExpanded,
      children: root.children.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}

// One entry in the multilevel list displayed by this app.
class Entry {
  Entry(
  this.widget,
  [this.children = const <Entry>[],
  this.initiallyExpanded = false]);

  final Widget widget;
  final List<Entry> children;
  final bool initiallyExpanded;
}

class recentlyPlayedWidget extends StatelessWidget {
  const recentlyPlayedWidget({
    Key key,
    @required NavigationBloc navigationBloc,
  })  : _navigationBloc = navigationBloc,
        super(key: key);

  final NavigationBloc _navigationBloc;

  @override
  Widget build(BuildContext context) {
    final List<Entry> data = <Entry>[
      Entry(
        Text("What's New"),
        <Entry>[
          Entry(
            Container(height: max(MediaQuery.of(context).size.height - 300, 150), child: whatsNewBuilder()),
          ),
        ],
      ),
      Entry(
        Text('Recently Played'),
        <Entry>[
          Entry(
            Container(height: max(MediaQuery.of(context).size.height - 300, 150), child: recentlyPlayedBuilder()),
          ),
        ],
      ),
    ];

    return Scaffold(
        body: ListView.builder(
      itemBuilder: (BuildContext context, int index) => EntryItem(data[index]),
      itemCount: data.length,
    ));
  }

  FutureBuilder<List<Episode>> whatsNewBuilder() {
    return FutureBuilder<List<Episode>>(
        future: getLatestFromSubscriptions(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Episode> data = snapshot.data;
            return episodeListView(
                _navigationBloc, data, PageStorageKey('whatsNew'));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return CircularProgressIndicator();
        });
  }

  FutureBuilder<List<Episode>> recentlyPlayedBuilder() {
    return FutureBuilder<List<Episode>>(
        future: getRecentlyPlayed(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Episode> data = snapshot.data;
            return episodeListView(
                _navigationBloc, data, PageStorageKey('recentlyPlayed'));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return CircularProgressIndicator();
        });
  }
}
