import 'package:image/image.dart';

import 'episode.dart';

class Show {
  final String title;
  final int duration; // in ms
  final Image image;
  final DateTime published;
  final List<Episode> episodes;

  Show({this.title, this.duration, this.image, this.published, this.episodes});
}
