import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podcastsync/bloc/bloc-prov.dart';
import 'package:podcastsync/screens/navigation-bloc.dart';

class LibraryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NavigationBloc _navigationBloc = BlocProvider.of(context);
    return Icon(Icons.library_music);
  }
}
