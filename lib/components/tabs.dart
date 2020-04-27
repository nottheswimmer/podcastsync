import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar(this.color, this.tabBar);

  /// Color of the container to wrap around the tab bar
  final Color color;

  /// The tab bar
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
    color: color,
    child: tabBar,
  );
}
