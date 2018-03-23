import 'package:flutter/material.dart';

import '../user.dart';
import '../server.dart';
import 'login.dart';
import 'users.dart';

const List<String> StateStrings = const ['Connecting...', 'Connected',
  'Disconnecting...', 'Disconnected', 'Registered', 'In conversation'];

class Home extends StatelessWidget {
  Home({this.server, this.user, this.login, this.logout,
    this.toggleNightMode});

  final Server server;
  final User user;
  final Function login;
  final Function logout;
  final Function toggleNightMode;

  void _showInfo(context) {
    String stateString = server != null ? StateStrings[user.state.index] :
    'Disconnected';
    bool isNotDisconnected = server != null
      && user.state != UserState.disconnected;
    String serverString = isNotDisconnected
      ? server.host + ':'+ server.port.toString() : 'N/A';
    String usernameString = isNotDisconnected ? user.name : 'N/A';

    AlertDialog infoAlert = new AlertDialog(
      title: new Text('Status Information'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text('State: ' + stateString),
          new SizedBox(height: 10.0),
          new Text('Server: ' + serverString),
          new SizedBox(height: 10.0),
          new Text('Username: ' + usernameString)
        ]
      )
    );

    showDialog(context: context, child: infoAlert);
  }

  @override
  Widget build(BuildContext context) {
    Widget body = user?.state == UserState.connected
      ? new Users(logout: logout)
      : new Login(login: login, state: user?.state);

    return new Scaffold(
      appBar: new AppBar(
        leading: new Icon(Icons.dehaze),
        title: new Text("FlutterChat"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.brightness_4),
            onPressed: toggleNightMode
          ),
          new IconButton(
            icon: new Icon(Icons.info_outline),
            onPressed: () => _showInfo(context)
          )
        ]
      ),
      body: body
    );
  }
}