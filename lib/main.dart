import 'package:flutter/material.dart';
import 'package:podcastsync/bloc/bloc-prov-tree.dart';
import 'package:podcastsync/bloc/bloc-prov.dart';
import 'package:podcastsync/blocs/auth-bloc.dart';
import 'package:podcastsync/blocs/pref-bloc.dart';

import 'package:podcastsync/routes.dart';

void main() {
  runApp(PodcastSync());
}

class PodcastSync extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
        blocProviders: <BlocProvider>[
          BlocProvider<AuthBloc>(bloc: AuthBloc()),
          BlocProvider<PrefBloc>(bloc: PrefBloc()),
        ],
        child: MaterialApp(
          title: 'Podcast Sync',
          theme: ThemeData(
            primarySwatch: Colors.brown,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: '/',
          routes: routes,
        ));
  }
}
