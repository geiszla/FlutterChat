import 'package:flutter/material.dart';

class Users extends StatelessWidget {
  Users({this.logout});

  final Function logout;

  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Text('No online users.', style: _biggerFont),
          new SizedBox(height: 50.0),
          new RaisedButton(
            child: new Text('Log out'),
            onPressed: logout
          )
        ]
      )
    );
  }
}