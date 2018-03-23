import 'package:flutter/material.dart';

import '../server.dart';
import '../user.dart';
import '../util.dart';
import 'home.dart';

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
    setState(() {
      this.username = username != '' ? username : 'testuser';
      server = new Server(serverName != '' ? serverName : '192.168.43.14',
        9999);
      user = new User(this.username);
      user.state = UserState.connecting;
    });

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
      home: new Home(
        server: server,
        user: user,
        login: login,
        logout: logout,
        toggleNightMode: () => setState(() => _isNightModeOn = !_isNightModeOn)
      )
    );
  }
}

