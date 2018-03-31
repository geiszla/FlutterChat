import 'package:flutter/material.dart';

import '../user.dart';
import 'loading.dart';

class Login extends StatelessWidget {
  Login({this.login, this.state, this.usernameError});

  final UserState state;
  final Function login;
  final String usernameError;

  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _serverController = new TextEditingController();

  void _login(context) {
    String username = _usernameController.text;
    String serverName = _serverController.text;

    login(username, serverName, context);
  }

  @override
  Widget build(BuildContext context) {
    // If user is connecting, show loading screen
    if (state == UserState.connecting) {
      return new Loading(text: 'Connecting...');
    }

    AssetImage logo = Theme.of(context).brightness == Brightness.dark
      ? new AssetImage('assets/flutter_logo_dark.png')
      : new AssetImage('assets/flutter_logo.png');

    List<Widget> formElements = <Widget> [
      new Column(
        children: <Widget>[
          new TextField(
            controller: _usernameController,
            decoration: new InputDecoration(
              labelText: 'Username',
              errorText: usernameError
            ),
            autocorrect: false
          ),
          // TODO: Don't smart-change text on input
          new TextField(
            controller: _serverController,
            decoration: new InputDecoration(
              labelText: 'Server Name/IP',
            ),
            autocorrect: false
          )
        ]
      ),
      new RaisedButton(
        child: new Text('Connect'),
        onPressed: () => _login(context)
      )
    ];

    // If keyboard is closed, show logo
    bool isKeyboardHidden = MediaQuery.of(context).viewInsets.bottom == 0;
    if (isKeyboardHidden) {
      final List<Widget> logoElements = <Widget> [
        new Image(image: logo, width: 133.0, height: 133.0,)
      ];

      logoElements.addAll(formElements);
      formElements = logoElements;
    }

    return new Center(
      child: new Form(
        child: new Padding (
          padding: new EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 0.0),
          child: new Column (
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: formElements
          )
        )
      )
    );
  }
}
