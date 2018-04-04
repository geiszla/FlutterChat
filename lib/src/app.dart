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
  String _usernameError;

  bool _isNightModeOn = false;

  void _login(String username, String serverName, BuildContext context) async {
    // TODO: [2] Final variables
    RegExp serverRegex = new RegExp(r'([^:]*):?([0-9]{0,5})');
    Match serverMatch = serverRegex.firstMatch(serverName);

    String hostName = serverMatch.group(1) != '' ? serverMatch.group(1)
        : '192.168.0.98';
    int port = serverMatch.group(2) != '' ? int.parse(serverMatch.group(2))
        : 9999;

    setState(() {
      // Includes default username and server name/port for testing
      _username = username != '' ? username : 'testuser';
      _user = new User(this._username);
      _user.state = UserState.connecting;

      _usernameError = null;

      _server = new Server(hostName, port);
    });

    print('----------New Session----------');
    log('Connecting to ${_server.host} on port ${_server.port.toString()}...');

    try {
      await _server.connect();
      _server.register(this._username, (String _) {
        setState(() => _user.state = UserState.connected);
        log('Login successful.');
      }, onError: (response) {
        if (response.contains('Username')) {
          setState(() {
            _user.state = UserState.disconnected;
             _usernameError = response;
          });

          logError("Username already exists.");
        }

        // TODO: [1] Move error reporting to catch
      });
    } catch (exception) {
      logError("Disconnected.");
      showSnackbar('Connection failed. Error: ${exception.osError.message}',
        context);

      setState(() => _user.state = UserState.disconnected);
    }
  }

  void _logout() {
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
        title: const Text('Status Information'),
        content: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text('State: $stateString'),
            const SizedBox(height: 10.0),
            new Text('Server: $serverString'),
            const SizedBox(height: 10.0),
            new Text('Username: $usernameString')
          ]
        )
      );

      return infoAlert;
    }, context: context);
  }

  void _handleLogoutPress(BuildContext context) {
    showDialog(context: context, builder: (BuildContext context) {
      return new AlertDialog(
        title: const Text('Do you want to log out?'),
        actions: <Widget>[
          new FlatButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context)
          ),
          new FlatButton(
            child: const Text('Log out'),
            onPressed: () {
              _logout();
              Navigator.pop(context);
            }
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme accentTextTheme = Theme.of(context).accentTextTheme;
    TextTheme newTextTheme = accentTextTheme.copyWith(
        body1: const TextStyle(color: Colors.white)
    );

    ThemeData theme;
    if (_isNightModeOn) {
      theme = new ThemeData(
        brightness: Brightness.dark,
        buttonColor: Colors.grey[800],
        accentColor: Colors.white,
        accentTextTheme: newTextTheme
      );
    } else {
      theme = new ThemeData(
        brightness: Brightness.light,
        buttonColor: Colors.blue,
        buttonTheme: new ButtonThemeData(
          textTheme: ButtonTextTheme.primary
        ),
        accentTextTheme: newTextTheme
      );
    }

    return new MaterialApp(
      theme: theme,
      home: new Scaffold(
        appBar: new AppBar(
          leading: _user?.isLoggedIn == true ? new Builder(
            builder: (BuildContext context) {
              return new IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () => _handleLogoutPress(context)
              );
            }
          ) : null,
          title: const Text('Flutter Chat'),
          actions: <Widget>[
            new IconButton(
              icon: const Icon(Icons.brightness_4),
              onPressed: () => setState(() => _isNightModeOn = !_isNightModeOn)
            ),
            new Builder(
              builder: (BuildContext context) {
                return new IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showInfo(context)
                );
              }
            )
          ]
        ),
        body: _user?.state == UserState.connected
          ? new Users(user: _user, server: _server)
          : new Login(login: _login, state: _user?.state,
              usernameError: _usernameError)
      )
    );
  }
}

