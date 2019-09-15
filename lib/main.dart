import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:ui' as ui;

import 'scrolling/bidirectional_scroll.dart';

void main() => runApp(
    MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyApp())
    );

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  double paddingLeft = 0, paddingTop = 40;
  double frameX = 0, frameY = 0;
  double overlayWidth = 300, overlayHeight = 300;
  double frameWidth = 80, frameHeight = 100;
  double screenWidth, screenHeight;
  double contentWidth, contentHeight;

  bool isOverlayVisible = false;
  var pngBytes;

  StreamController<bool> overlayVisiblityController = new StreamController<bool>.broadcast();
  StreamController<bool> frameUpdateController = new StreamController<bool>.broadcast();
  GlobalKey _bidirectionalViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(executeAfterBuild);
    return Scaffold(body: _buildMainView());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    overlayVisiblityController.close();
    frameUpdateController.close();
  }

  void updateOverlayVisibility(bool isVisible) {
    isOverlayVisible = isVisible;
    overlayVisiblityController.sink.add(isVisible);
    frameUpdateController.sink.add(isVisible);
  }

  void onScrollUpdate(ScrollNotification scrollInfo) {
    double distance = scrollInfo.metrics.pixels;
//    if (distance >= scrollInfo.metrics.maxScrollExtent || distance <= scrollInfo.metrics.minScrollExtent) {
//      return;
//    }

    if (scrollInfo.metrics.axis == Axis.horizontal) {
//      double factor = (overlayWidth / contentWidth) * (frameWidth / screenWidth);
//      double value = distance * factor;
//      frameX  = scrollInfo.metrics.axisDirection == AxisDirection.right ? (frameX + value) : (frameX - value);
        frameX = ((distance / contentWidth) * overlayWidth) + paddingLeft;
    } else {
//      double factor = (overlayHeight / contentHeight)/4;
//      double value = distance * factor;
//      frameY  = scrollInfo.metrics.axisDirection == AxisDirection.down ? (frameY + value) : (frameY - value);
        frameY = ((distance / contentHeight) * overlayHeight) + paddingTop;
    }

    if (frameX == 0) {
      frameX = paddingLeft;
    }
    if (frameY == 0) {
      frameY = paddingTop;
    }
    frameUpdateController.sink.add(true);
  }

  void executeAfterBuild(Duration duration) {
    print("Duration  ${duration.inSeconds}");
    getDrawnImage();
  }

  Future<void> getDrawnImage() async {
    try {
      RenderRepaintBoundary boundary =
      _bidirectionalViewKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      contentWidth = image.width.roundToDouble();
      contentHeight = image.height.roundToDouble();

      if (contentWidth>contentHeight) {
        double factor = contentHeight/contentWidth;
        overlayHeight = overlayWidth * factor;
      } else {
        double factor = contentWidth / contentHeight;
        overlayHeight = (overlayWidth * factor);
      }

      frameWidth = (screenWidth/contentWidth) * overlayWidth;
      frameHeight = ((screenHeight/contentHeight) * overlayHeight) - 10 /* Need to find why to minus this*/;

      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      pngBytes = byteData.buffer.asUint8List();
      overlayVisiblityController.sink.add(isOverlayVisible);
      frameUpdateController.sink.add(true);
    } catch (e) {
      print(e);
    }
  }

  Widget _buildMainView() {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    return Stack(
      children: <Widget>[
        BiDirectionalScrollView(
          child: _buildChild(),
          onScrollStarted: () => updateOverlayVisibility(true),
          onScrollEnded: () => updateOverlayVisibility(false),
          onScrollUpdate: (ScrollNotification scrollInfo) => onScrollUpdate(scrollInfo),
        ),
        _buildOverlay(),
        _buildFrame()
      ],
    );
  }

  Widget _buildChild() {
    List<Widget> columnItems = List();

    for (int i = 0; i < 10; i++) {
      List<Widget> rowItems = List();
      rowItems.add(SizedBox(
        width: 10,
      ));
      for (int j = 0; j < 20; j++) {
        rowItems.add(Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.all(Radius.elliptical(10, 10))),
          alignment: Alignment.center,
          child: Text("Item index $i:$j"),
        ));
        rowItems.add(SizedBox(
          width: 10,
        ));
      }

      columnItems.add(SizedBox(
        height: 10,
      ));
      columnItems.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rowItems,
      ));
    }

    return RepaintBoundary(
      key: _bidirectionalViewKey,
      child: Column(
        children: columnItems,
      ),
    );
  }

  Widget _buildOverlay() {
    return StreamBuilder<bool>(
      initialData: isOverlayVisible,
      stream: overlayVisiblityController.stream,
      builder: (context, snapshot) {
        return Visibility(
          visible: snapshot.data,
          child: Padding(
            padding: EdgeInsets.only(top: paddingTop, left: paddingLeft),
            child: Container(
              color: Colors.black26,
              width: overlayWidth,
              height: overlayHeight,
              child: pngBytes != null ? Image.memory(pngBytes) : null,
            ),
          ),
        );
      }
    );
  }

  Widget _buildFrame() {
    return StreamBuilder<bool>(
      stream: frameUpdateController.stream,
      builder: (context, snapshot) {
        return Positioned(
          child: isOverlayVisible ? Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                    color: Colors.white, style: BorderStyle.solid, width: 2)),
              width: frameWidth,
              height: frameHeight
          ) : SizedBox.shrink(),
          left: frameX,
          top: frameY,
        );
      }
    );
  }
}
