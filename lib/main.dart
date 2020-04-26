import 'package:chewie_audio/chewie_audio.dart';
import 'package:flutter/material.dart';

import 'package:podcastsync/episode.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Podcast Sync',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.brown,
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: DefaultTabController(
          length: 3,
          child: MyHomePage(title: 'Podcast Sync'),
        ));
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Future<List<Episode>> futureFeed;
  VideoPlayerController _controller;
  ChewieAudioController chewieController;
  ChewieAudio playerWidget;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    futureFeed = searchSpreakerEpisodes('nightvale');
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Widget _HomePage() {
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[
            FutureBuilder<List<Episode>>(
              future: futureFeed,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data[0].image;
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
            Text(
              'Clicked this many times: ',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _SearchPage() {
    return Scaffold(
        body: Center(
      child: FutureBuilder<List<Episode>>(
        future: futureFeed,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Episode> data = snapshot.data;
            return _episodeListView(data);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    ));
  }

  play(String url) async {
    if (chewieController != null) {
      chewieController.dispose();
    }

    if (_controller != null) {
      _controller.dispose();
    }

    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        chewieController = ChewieAudioController(
          videoPlayerController: _controller,
          autoPlay: true,
          looping: false,
          allowMuting: false,
        );
        playerWidget = ChewieAudio(controller: chewieController);
        setState(() {});
      }
      );
  }

  ListTile _episodeTile(
          String title, String subtitle, Image icon, String download_url) =>
      ListTile(
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text(subtitle),
        leading: icon,
        onTap: () {
          play(download_url);
          setState(() {});
        },
      );

  ListView _episodeListView(List<Episode> data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _episodeTile(data[index].title, data[index].show,
              data[index].image, data[index].download_url);
        });
  }

  @override
  Widget build(BuildContext context) {
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
          title: Text(widget.title),
        ),
        bottomNavigationBar: ColoredTabBar(
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
        body: TabBarView(
          children: [
            _HomePage(),
            _SearchPage(),
            Icon(Icons.library_music),
          ], // This trailing comma makes auto-formatting nicer for build methods.
        ),
        persistentFooterButtons: <Widget>[
          Visibility(
              visible: _controller != null,
              child: Container(
                  color: Colors.white,
                  height: 60,
                  child: playerWidget)
          )]
    );
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
