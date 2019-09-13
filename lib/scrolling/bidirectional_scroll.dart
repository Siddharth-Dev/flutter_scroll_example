import 'package:flutter/material.dart';

class BiDirectionalScrollView extends StatefulWidget {

  final Widget child;
  final VoidCallback onScrollStarted;
  final VoidCallback onScrollEnded;
  final Function(ScrollNotification) onScrollUpdate;

  BiDirectionalScrollView({@required this.child, this.onScrollStarted, this.onScrollEnded, this.onScrollUpdate});

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
    
    return NotificationListener<ScrollNotification>(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          _buildChild()
        ],
      ),
      onNotification: (ScrollNotification scrollNotification) {
        if (scrollNotification is ScrollStartNotification) {
          widget.onScrollStarted();
        } else if (scrollNotification is ScrollUpdateNotification) {
          widget.onScrollUpdate(scrollNotification);
        } else if (scrollNotification is ScrollEndNotification) {
          widget.onScrollEnded();
        }

        return false;
      },
    );
  }
  
  Widget _buildChild() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: widget.child,
    );
  }
}