import 'package:flutter/material.dart';

import '../server.dart';
import '../user.dart';
import '../util.dart';
import 'login.dart';
import 'users.dart';

const List<String> StateStrings = const ['Connecting...', 'Connected',
  'Disconnecting...', 'Disconnected', 'Registered', 'In conversation'];

class App extends StatefulWidget {
  @override
  AppState createState() => new AppState();
}

class AppState extends State<App> {
  Server server;
  User user;
  String username;
  bool _isNightModeOn = false;

  void login(String username, String serverName, BuildContext context) async {
    // TODO: [1] Parse port from server name
    setState(() {
      // Default username and server name values for testing
      this.username = username != '' ? username : 'testuser';
      server = new Server(serverName != '' ? serverName : '192.168.43.14',
        9999);

      user = new User(this.username);
      user.state = UserState.connecting;
    });

    // TODO: [2] Test connection with BarryBot
    try {
      log('Connecting to ' + server.host + ' on port '
          + server.port.toString() + '...');

      await server.connect();
      server.register(this.username);
      setState(() => user.state = UserState.connected);

      log('Successfully logged in.');
    } catch(exception) {
      logError("Couldn't log in.");
      showAlert('Connection failed. Error: ' + exception.osError.message,
        context);

      setState(() => user.state = UserState.disconnected);
    }
  }

  void logout() async {
    setState(() => user.state = UserState.disconnecting);

    try {
      await server.disconnect();
    } catch (exception) {
      logWarning('An error occurred while disconnecting from server.');
    }

    setState(() => user.state = UserState.disconnected);
  }

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
    ThemeData theme;
    if (_isNightModeOn) {
      theme = new ThemeData(
        brightness: Brightness.dark,
        buttonColor: Colors.grey[800],
        accentColor: Colors.white
      );
    } else {
      theme = new ThemeData(
        brightness: Brightness.light,
        buttonColor: Colors.blue,
        buttonTheme: new ButtonThemeData(
          textTheme: ButtonTextTheme.primary
        )
      );
    }

    Widget body = user?.state == UserState.connected
      ? new Users(logout: logout)
      : new Login(login: login, state: user?.state);

    return new MaterialApp(
      theme: theme,
      home: new Scaffold(
        appBar: new AppBar(
          leading: new Icon(Icons.dehaze),
          title: new Text("Flutter Chat"),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.brightness_4),
              onPressed: () => setState(() => _isNightModeOn = !_isNightModeOn)
            ),
            new Builder(
              builder: (BuildContext context) {
                return new IconButton(
                    icon: new Icon(Icons.info_outline),
                    onPressed: () => _showInfo(context)
                );
              }
            )
          ]
        ),
        body: body
      )
    );
  }
}

