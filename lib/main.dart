import 'package:flutter/material.dart';

import 'scrolling/bidirectional_scroll.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        primarySwatch: Colors.blue,
      ),
      home: BiDirectionalScrollView(
        child: _buildChild(),
        onScrollStarted: () => print("Start"),
        onScrollEnded: () => print("End"),
        onScrollUpdate: (ScrollNotification scrollInfo) => print("Direction ${scrollInfo.metrics.axis == Axis.vertical ? "Vertical" : "Horizontal"}, Values ${scrollInfo.metrics.pixels}")
        ,
      ),
    );
  }


  Widget _buildChild() {

    List<Widget> columnItems = List();

    for (int i=0;i<10;i++) {

      List<Widget> rowItems = List();
      rowItems.add(SizedBox(width: 10,));
      for(int j=0;j<20;j++) {
        rowItems.add(Container(width: 100, height: 100, decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.all(Radius.elliptical(10, 10))), alignment: Alignment.center, child: Text("Item index $i:$j"),));
        rowItems.add(SizedBox(width: 10,));
      }

      columnItems.add(SizedBox(height: 10,));
      columnItems.add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center, children: rowItems, ));
    }

    return Column(
        children: columnItems,
      );
  }
}
