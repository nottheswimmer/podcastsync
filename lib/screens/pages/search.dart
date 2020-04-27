import 'package:intl/intl.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:podcastsync/bloc/bloc-prov.dart';
import 'package:podcastsync/components/episodes.dart';
import 'package:podcastsync/components/shows.dart';
import 'package:podcastsync/components/tabs.dart';
import 'package:podcastsync/models/episode.dart';
import 'package:podcastsync/models/show.dart';
import 'package:podcastsync/providers/spreaker.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NavigationBloc _navigationBloc = BlocProvider.of(context);
    return Scaffold(
        body: SafeArea(
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ColoredTabBar(
                    Colors.white,
                    TabBar(
                      tabs: [
                        Tab(
                          text: "Shows",
                        ),
                        Tab(text: "Episodes"),
                      ],
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.grey,
                    )),
              ],
            ),
            body: TabBarView(
              children: <Widget>[
                SearchBar<Show>(
                    onSearch: searchSpreakerShows,
                    emptyWidget: Text('No shows to display'),
                    placeHolder: Center(child: Text('Search for shows')),
                    searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
                    headerPadding: EdgeInsets.symmetric(horizontal: 10),
                    listPadding: EdgeInsets.symmetric(horizontal: 10),
                    onItemFound: (Show show, int index) {
                      String lastEpisodeTimeString = DateFormat.yMd()
                          .add_jm()
                          .format(show.last_episode_at.toLocal());
                      return showTile(
                          _navigationBloc,
                          show.title,
                          'Last episode at $lastEpisodeTimeString',
                          show.image,
                          show.episodes,
                          context);
                    }),
                SearchBar<Episode>(
                    onSearch: searchSpreakerEpisodes,
                    emptyWidget: Text('No episodes to display'),
                    placeHolder: Center(child: Text('Search for episodes')),
                    searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
                    headerPadding: EdgeInsets.symmetric(horizontal: 10),
                    listPadding: EdgeInsets.symmetric(horizontal: 10),
                    onItemFound: (Episode episode, int index) {
                      return episodeTile(_navigationBloc, episode.title,
                          episode.show, episode.image, episode.toMediaItem());
                    }),
              ],
            ),
          )),
    ));
  }
}
