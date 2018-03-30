import 'package:flutter/material.dart';

import '../server.dart';
import '../user.dart';
import '../util.dart';
import 'login.dart';
import 'users.dart';

class App extends StatefulWidget {
  @override
  AppState createState() => new AppState();
}

class AppState extends State<App> {
  Server _server;
  User _user;
  String _username;
  bool _isNightModeOn = false;

  void login(String username, String serverName, BuildContext context) async {
    // TODO: [1] Parse port from server name
    setState(() {
      // Includes default username and server name for testing
      this._username = username != '' ? username : 'testuser';
      _server = new Server(serverName != '' ? serverName : '192.168.0.98',
        9999);

      _user = new User(this._username);
      _user.state = UserState.connecting;
    });

    print('----------New Session----------');
    log('Connecting to ${_server.host} on port ${_server.port.toString()}...');

    try {
      await _server.connect();
      _server.register(this._username);

      setState(() => _user.state = UserState.connected);
      log('Login successful.');
    } catch(exception) {
      logError("Couldn't log in.");
      showSnackbar('Connection failed. Error: ${exception.osError.message}',
        context);

      setState(() => _user.state = UserState.disconnected);
    }
  }

  void logout() {
    setState(() => _user.state = UserState.disconnecting);

    try {
      _server.disconnect(callback: () {
        log('Logout successful.');
        print('----------End of Session----------');
      });
    } catch (exception) {
      logWarning('An error occurred while disconnecting from server.');
    }

    setState(() => _user.state = UserState.disconnected);
  }

  void _showInfo(context) {
    showDialog(builder: (BuildContext context) {
      String stateString = _server != null ? _user.stateString : 'Disconnected';

      bool isNotDisconnected = _server != null
        && _user.state != UserState.disconnected;
      String serverString = isNotDisconnected
        ? '${_server.host}:${_server.port.toString()}' : 'N/A';
      String usernameString = isNotDisconnected ? _user.name : 'N/A';

      AlertDialog infoAlert = new AlertDialog(
        title: new Text('Status Information'),
        content: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text('State: $stateString'),
            new SizedBox(height: 10.0),
            new Text('Server: $serverString'),
            new SizedBox(height: 10.0),
            new Text('Username: $usernameString')
          ]
        )
      );

      return infoAlert;
    }, context: context);
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

    return new MaterialApp(
      theme: theme,
      home: new Scaffold(
        appBar: new AppBar(
          leading: new Icon(Icons.dehaze),
          title: new Text('Flutter Chat'),
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
        body: _user?.state == UserState.connected
          ? new Users(user: _user, logout: logout, server: _server)
          : new Login(login: login, state: _user?.state)
      )
    );
  }
}

