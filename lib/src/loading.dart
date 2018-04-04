import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String text;
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  Loading({this.text});

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(height: 50.0),
          new Text(text, style: _biggerFont)
        ]
      )
    );
  }
}