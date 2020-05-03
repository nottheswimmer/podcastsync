import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podcastsync/bloc/bloc-prov.dart';
import 'package:podcastsync/components/shows.dart';
import 'package:podcastsync/models/show.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';

class LibraryPage extends StatelessWidget {
  NavigationBloc _navigationBloc;

  @override
  Widget build(BuildContext context) {
    _navigationBloc = BlocProvider.of(context);
    return subscriptionsBuilder();
  }

  FutureBuilder<List<Show>> subscriptionsBuilder() {
    return FutureBuilder<List<Show>>(
        future: getSubscriptions(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Show> data = snapshot.data;
            return showListView(
                _navigationBloc, data, PageStorageKey('subscriptions'));
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return CircularProgressIndicator();
        });
  }
}
