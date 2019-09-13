import 'package:flutter/material.dart';

class ScrollOperation extends StatefulWidget {


  @override
  _ScrollOperationState createState() => _ScrollOperationState();
}

abstract class ScrollListener {
  void onScrollStarted();
  void onScrollEnded();
  void scrollMovement(double x, double y);
}

class _ScrollOperationState extends State<ScrollOperation> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

    );
  }
}