import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  Loading({this.text});

  final String text;
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new CircularProgressIndicator(),
          new SizedBox(height: 50.0),
          new Text(text, style: _biggerFont)
        ]
      )
    );
  }
}