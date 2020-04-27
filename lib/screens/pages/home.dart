import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podcastsync/bloc/bloc-prov.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';
import 'package:podcastsync/screens/navigation-events.dart';

class HomePage extends StatelessWidget {
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
