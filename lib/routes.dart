import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:podcastsync/screens/navigation.dart';

import 'components/audio.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/": (BuildContext context) => AudioServiceWidget(child: Navigation()),
};