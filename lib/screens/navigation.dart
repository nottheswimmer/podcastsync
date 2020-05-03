import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podcastsync/bloc/bloc-prov.dart';
import 'package:podcastsync/blocs/pref-bloc.dart';
import 'package:podcastsync/components/audio.dart';
import 'package:podcastsync/components/tabs.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';
import 'package:podcastsync/screens/pages/home.dart';
import 'package:podcastsync/screens/pages/library.dart';
import 'package:podcastsync/screens/pages/search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Navigation extends StatefulWidget {
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  NavigationBloc navigationBloc;
  PrefBloc prefBloc;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    navigationBloc = NavigationBloc();
  }

  @override
  void dispose() {
    navigationBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    prefBloc = BlocProvider.of(context);
    return BlocProvider(
        bloc: navigationBloc,
        child: DefaultTabController(
          length: 3,
          child: NavigationScreen(title: 'Podcast Sync'),
        ));
  }
}

class NavigationScreen extends StatelessWidget {
  NavigationScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          MediaPlayer(),
          _NavigationBar(),
        ],
      ),
      body: _NavigationArea(),
      // Should the body resize when the keyboard appears?
      resizeToAvoidBottomInset: true,
      extendBody: false,
    );
  }
}

class _NavigationArea extends StatelessWidget {
  const _NavigationArea({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        HomePage(),
        SearchPage(),
        LibraryPage(),
      ],
    );
  }
}

class _NavigationBar extends StatelessWidget {
  const _NavigationBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredTabBar(
        Colors.brown,
        TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.home),
              text: "Home",
            ),
            Tab(icon: Icon(Icons.search), text: "Discover"),
            Tab(icon: Icon(Icons.subscriptions), text: "Library"),
          ],
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.black87,
        ));
  }
}
