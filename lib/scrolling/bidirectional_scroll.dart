import 'package:flutter/material.dart';

class BiDirectionalScrollView extends StatefulWidget {
  
  @override
  _BiDirectionalScrollViewState createState() => _BiDirectionalScrollViewState();
  
}

class _BiDirectionalScrollViewState extends State<BiDirectionalScrollView> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scrolling Demo"),),
        body: _buildView());
  }
  
  
  Widget _buildView() {
    
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        _buildChild()
      ],
    );;
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
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: columnItems,
      ),
    );
  }
}