import 'package:audio_service/audio_service.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podcastsync/bloc/bloc-prov.dart';
import 'package:podcastsync/components/audio.dart';
import 'package:podcastsync/screens/navigation-events.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';

import '../episode.dart';

class Navigation extends StatefulWidget {
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  NavigationBloc navigationBloc;

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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  Widget build(BuildContext context) {
    final NavigationBloc _navigationBloc = BlocProvider.of(context);

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          MediaPlayer(),
          ColoredTabBar(
              Colors.brown,
              TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.home),
                    text: "Home",
                  ),
                  Tab(icon: Icon(Icons.search), text: "Discover"),
                  Tab(icon: Icon(Icons.library_music), text: "Library"),
                ],
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.white,
                indicatorColor: Colors.black87,
              )),
        ],
      ),
      body: TabBarView(
        children: [
          _HomePage(),
          _SearchPage(),
          Icon(Icons.library_music),
        ], // This trailing comma makes auto-formatting nicer for build methods.
      ),
      // Should the body resize when the keyboard appears?
      resizeToAvoidBottomInset: true,
      extendBody: false,
    );
  }
}

class _HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NavigationBloc _navigationBloc = BlocProvider.of(context);
    return clickerWidget(navigationBloc: _navigationBloc);
  }
}

class clickerWidget extends StatelessWidget {
  const clickerWidget({
    Key key,
    @required NavigationBloc navigationBloc,
  })  : _navigationBloc = navigationBloc,
        super(key: key);

  final NavigationBloc _navigationBloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _clickerDisplayWidget(navigationBloc: _navigationBloc)
          ],
        ),
      ),
      floatingActionButton: _clickerIncrementButton(),
    );
  }

  FloatingActionButton _clickerIncrementButton() {
    return FloatingActionButton(
      onPressed: () =>
          _navigationBloc.counterEventSink.add(CounterIncrementEvent()),
      tooltip: 'Increment',
      child: Icon(Icons.add),
    );
  }
}

class _clickerDisplayWidget extends StatelessWidget {
  const _clickerDisplayWidget({
    Key key,
    @required NavigationBloc navigationBloc,
  })  : _navigationBloc = navigationBloc,
        super(key: key);

  final NavigationBloc _navigationBloc;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: StreamBuilder(
            stream: _navigationBloc.counterStream,
            initialData: _navigationBloc.counter,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '${snapshot.data}',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              );
            }));
  }
}

class _SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NavigationBloc _navigationBloc = BlocProvider.of(context);
    return Scaffold(
        body: SafeArea(
      child: SearchBar<Episode>(
        onSearch: searchSpreakerEpisodes,
        searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
        headerPadding: EdgeInsets.symmetric(horizontal: 10),
        listPadding: EdgeInsets.symmetric(horizontal: 10),
        onItemFound: (Episode episode, int index) {
          return _episodeTile(_navigationBloc, episode.title,
          episode.show, episode.image, episode.toMediaItem());
        }
      ),
    ));
  }

  ListTile _episodeTile(NavigationBloc _navigationBloc, String title,
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

  ListView _episodeListView(
      NavigationBloc _navigationBloc, List<Episode> data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _episodeTile(_navigationBloc, data[index].title,
              data[index].show, data[index].image, data[index].toMediaItem());
        });
  }
}

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar(this.color, this.tabBar);

  final Color color;
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
        color: color,
        child: tabBar,
      );
}
