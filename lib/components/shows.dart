import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podcastsync/bloc/bloc-prov.dart';
import 'package:podcastsync/components/audio.dart';
import 'package:podcastsync/components/episodes.dart';
import 'package:podcastsync/models/episode.dart';
import 'package:podcastsync/models/show.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

Widget showTile(

        /// Navigation bloc which provides audio playback controls
        final NavigationBloc _navigationBloc,
        final Show show,

        /// Build context to pass to the show episodes popup
        final BuildContext context) =>
    ListTile(
        title: Text(show.title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text(
            'Last episode ${timeago.format(show.last_episode_at.toLocal())}'),
        leading: show.image,
        onTap: () async {
          _navigationBloc.subscribedToCurrentshow = await isSubscribed(show);

          return Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BlocProvider(
                      bloc: _navigationBloc,
                      child: Scaffold(
                        appBar: AppBar(title: Text(show.title)),
                        body: SizedBox(
                            child: FutureBuilder<List<Episode>>(
                                future: show.episodes,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<Episode> data = snapshot.data;
                                    return episodeListView(
                                        _navigationBloc,
                                        data,
                                        PageStorageKey('searchedEpisodes'));
                                  } else if (snapshot.hasError) {
                                    return Text("${snapshot.error}");
                                  }
                                  // By default, show a loading spinner.
                                  return CircularProgressIndicator();
                                })),
                        floatingActionButton:
                            _navigationBloc.subscribedToCurrentshow
                                ? FloatingActionButton(
                                    child: Icon(Icons.remove),
                                    onPressed: () async {
                                      await removeShowFromSubscriptions(show);
                                      _navigationBloc.subscribedToCurrentshow =
                                          false;
                                      // Update UI
                                      (context as Element).markNeedsBuild();
                                    },
                                  )
                                : FloatingActionButton(
                                    child: Icon(Icons.add),
                                    onPressed: () async {
                                      await addShowToSubscriptions(show);
                                      _navigationBloc.subscribedToCurrentshow =
                                          true;
                                      // Update UI
                                      (context as Element).markNeedsBuild();
                                    },
                                  ),
                        persistentFooterButtons: <Widget>[
                          MediaPlayer(),
                        ],
                      ))));
        });

ListView showListView(
  /// Navigation bloc which provides audio playback controls
  final NavigationBloc _navigationBloc,

  /// List of episodes that display in the ListView
  final List<Show> shows,
  final PageStorageKey key,
) {
  return ListView.builder(
      key: key,
      itemCount: shows.length,
      itemBuilder: (context, index) {
        return showTile(_navigationBloc, shows[index], context);
      });
}

Future<bool> isSubscribed(Show show) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Store the thing being played in the play history
  if (prefs.containsKey('subscriptions')) {
    List<String> subscriptions = prefs.getStringList('subscriptions');
    // Remove instances of the show from the subscriptions list
    for (String jsonShow in subscriptions) {
      Map<String, dynamic> decoded = jsonDecode(jsonShow);
      if (decoded['title'] == show.title &&
          decoded['provider'] == show.provider) {
        return true;
      }
    }
    ;
  }
  return false;
}

Future<List<Show>> getSubscriptions() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Store the thing being played in the play history
  if (prefs.containsKey('subscriptions')) {
    List<String> subscriptionStringList = prefs.getStringList('subscriptions');
    // Remove instances of the show from the subscriptions list
    List<dynamic> subscriptionJsonList = subscriptionStringList
        .map((e) => jsonDecode(e))
        .toList(growable: false);
    List<Show> subscriptionList =
        subscriptionJsonList.map((e) => Show.fromJson(e)).toList();
    subscriptionList
        .sort((a, b) => a.last_episode_at.isBefore(b.last_episode_at) ? 1 : -1);
    return subscriptionList;
  }
  return [];
}

Future addShowToSubscriptions(Show show) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Store the thing being played in the play history
  if (prefs.containsKey('subscriptions')) {
    List<String> subscriptions = prefs.getStringList('subscriptions');
    // Remove instances of the show from the subscriptions list
    subscriptions.removeWhere((jsonShow) {
      Map<String, dynamic> decoded = jsonDecode(jsonShow);
      return (decoded['title'] == show.title &&
          decoded['provider'] == show.provider);
    });
    // Add this item to the recently played list
    subscriptions.add(jsonEncode(show.toJson()));
    prefs.setStringList('subscriptions', subscriptions);
  } else {
    // If the key doesn't exist, make it.
    prefs.setStringList('subscriptions', [jsonEncode(show.toJson())]);
  }
}

Future removeShowFromSubscriptions(Show show) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Store the thing being played in the play history
  if (prefs.containsKey('subscriptions')) {
    List<String> subscriptions = prefs.getStringList('subscriptions');
    // Remove instances of the show from the subscriptions list
    subscriptions.removeWhere((jsonShow) {
      Map<String, dynamic> decoded = jsonDecode(jsonShow);
      return (decoded['title'] == show.title &&
          decoded['provider'] == show.provider);
    });
    prefs.setStringList('subscriptions', subscriptions);
  }
}
