import 'package:flutter/material.dart';

class BoundingBox extends StatelessWidget {
  double xmax;
  double xmin;
  double ymax;
  double ymin;
  double confidence;
  String name;

  late double width;
  late double height;

  BoundingBox(
      {super.key,
      required this.xmax,
      required this.xmin,
      required this.ymax,
      required this.ymin,
      required this.name,
      required this.confidence}) {
    width = xmax - xmin;
    height = ymax - ymin;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(left: xmin, top: ymin),
          width: width,
          height: height,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 2)),
        ),
        Container(
          margin: EdgeInsets.only(left: xmin, top: ymin),
          height: height,
          child: Text(
            "$name: ${(confidence * 100).ceil()}%",
            style: const TextStyle(
                color: Colors.white, backgroundColor: Colors.blueAccent),
          ),
        ),
      ],
    );
  }
}
