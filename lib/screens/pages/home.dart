import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podcastsync/bloc/bloc-prov.dart';
import 'package:podcastsync/components/episodes.dart';
import 'package:podcastsync/models/episode.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NavigationBloc _navigationBloc = BlocProvider.of(context);
    return recentlyPlayedWidget(navigationBloc: _navigationBloc);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class recentlyPlayedWidget extends StatelessWidget {
  const recentlyPlayedWidget({
    Key key,
    @required NavigationBloc navigationBloc,
  })  : _navigationBloc = navigationBloc,
        super(key: key);

  final NavigationBloc _navigationBloc;

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

  SliverPersistentHeader makeHeader(String headerText) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 60.0,
        maxHeight: 200.0,
        child: Container(
            color: Colors.lightBlue, child: Center(child: Text(headerText))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
      Container(
        alignment: Alignment.bottomCenter,
          child: buildFutureBuilder()),
    ]);
  }

  FutureBuilder<List<Episode>> buildFutureBuilder() {
    return FutureBuilder<List<Episode>>(
            future: getRecentlyPlayed(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Episode> data = snapshot.data;
                return episodeListViewWithHeader(_navigationBloc, data, "Recently Played");
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner.
              return CircularProgressIndicator();
            });
  }
}
