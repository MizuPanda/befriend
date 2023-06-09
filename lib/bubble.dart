import 'package:flutter/material.dart';
import 'dart:math';

class Bubble {
  final String name;
  final double distance;
  final double size;

  Bubble({required this.name, required this.distance, required this.size});
}

class BubbleWidget extends StatelessWidget {
  final Bubble bubble;
  final Color? color;
  const BubbleWidget({Key? key, required this.bubble, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: bubble.size,
        height: bubble.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Center(
          child: Text(
            bubble.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class Area {
  Point point;
  double size;

  Area(this.point, this.size);
}

class Point {
  double x;
  double y;

  Point(this.x, this.y);
}

class FriendBubbleWidget extends StatefulWidget {
  final Bubble main;
  final Bubble friend;
  final List<Area> areas;
  const FriendBubbleWidget(
      {Key? key, required this.main, required this.friend, required this.areas})
      : super(key: key);

  @override
  State<FriendBubbleWidget> createState() => _FriendBubbleWidgetState();
}

class _FriendBubbleWidgetState extends State<FriendBubbleWidget> {
  late double top;
  late double bottom;
  late double right;
  late double left;
  late Color color;
  @override
  void initState() {
    final double distance = widget.friend.distance;
    double i = 0;

    final double size = widget.friend.size;
    final double dist = widget.main.size + size;

    Point point = Point(0, 0);
    bool freeArea = false;

    //Make it so distance is more impactful, even more when we'll be able to move the map
    //ANGLE SHOULD BE BASED ON THE CLOSENESS BETWEEN THOSE FRIENDS, IF POSSIBLE
    while (!freeArea) {
      debugPrint('i: $i');
      freeArea = true;
      double sinus = sin(distance + size + i);
      double cosine = cos(distance + size  + i);

      if (sinus >= 0) {
        top = 0;
        bottom = dist + sinus * distance;
        point.y = bottom;
      } else {
        top = dist - sinus * distance;
        bottom = 0;
        point.y = -top;
      }
      if (cosine >= 0) {
        left = dist + cosine * distance;
        right = 0;
        point.x = left;
      } else {
        left = 0;
        right = dist - cosine * distance;
        point.x = -right;
      }
      double xMax = point.x + size;
      double xMin = point.x - size;
      double yMax = point.y + size;
      double yMin = point.y - size;

      for (Area area in widget.areas) {
        double xMAX = area.point.x + size;
        double xMIN = area.point.x - size;
        double yMAX = area.point.y + size;
        double yMIN = area.point.y - size;

        bool possX1 = xMax > xMIN && xMax <= xMAX;
        bool possY1 = yMax > yMIN && yMax <= yMAX;
        bool possX2 = xMin < xMAX && xMin >= xMIN;
        bool possY2 = yMin < yMAX && yMin >= yMIN;

        if ((possX1 && possY1) ||
            (possX1 && possY2) ||
            (possX2 && possY2) ||
            (possX2 && possY1)) {
          freeArea = false;
          i+= pi/6;
        }
      }
    }

    Random r = Random();
    int max = 255;
    color = Color.fromRGBO(r.nextInt(max), r.nextInt(max), r.nextInt(max), 1);
    widget.areas.add(Area(point, size));
    //debugPrint('x: ${point.x} and y: ${point.y}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin:
            EdgeInsets.only(left: left, right: right, top: top, bottom: bottom),
        child: BubbleWidget(
          bubble: widget.friend,
          color: color,
        ));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Bubble> bubbles = [
    Bubble(name: 'Friend 1', distance: 40, size: 60),
    Bubble(name: 'Friend 2', distance: 30, size: 80),
    Bubble(name: 'Friend 3', distance: 50, size: 100),
    Bubble(name: 'Friend 4', distance: 75, size: 75)
    // Add more bubbles as needed
  ];

  @override
  Widget build(BuildContext context) {
    final Bubble main = Bubble(name: 'Connected User', distance: 0, size: 120);
    final List<Area> areas = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bubble App'),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Stack(
            children: [
              BubbleWidget(
                bubble: main,
                color: Colors.red,
              ),
              for (Bubble bubble in bubbles)
                FriendBubbleWidget(main: main, friend: bubble, areas: areas)
            ],
          ),
        ),
      ),
    );
  }
}
