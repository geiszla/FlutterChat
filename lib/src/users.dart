import 'package:flutter/material.dart';

import '../server.dart';
import '../user.dart';
import '../util.dart';
import 'chat.dart';

class Users extends StatefulWidget {
  Users({this.user, this.logout, this.server});

  final User user;
  final Function logout;
  final Server server;

  @override
  UsersState createState() => new UsersState();
}

class UsersState extends State<Users> {
  List<String> _onlineUsers;

  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  void _getUsers() {
    widget.server.getUsers((response) {
      RegExp listRegex = new RegExp(r"WHO\s*\[((?:'[^']*',?\s*)*)\]");
      Match listMatch = listRegex.firstMatch(response);

      if (listMatch == null) return;

      List<String> matchList = listMatch[1].split(',');
      RegExp nameRegex = new RegExp(r"'(.*)'");
      Iterable<String> usernames = matchList.map((listElement) {
        Match nameMatch = nameRegex.firstMatch(listElement);
        return nameMatch[1];
      }).where((username) => username != widget.user.name);

      setState(() => _onlineUsers = usernames.toList());
      log('Online users: ${usernames.length > 0 ? usernames : '<none>'}');
    });
  }

  void _openChat(String username) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Chat(partnerUsername: username);
        }
      )
    );
  }

  @override
  void initState() {
    super.initState();
    _getUsers();
  }

  @override
  Widget build(BuildContext context) {
    Widget usersWidget = new Center(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Text('No online users.', style: _biggerFont),
          new SizedBox(height: 50.0),
          new RaisedButton(
            child: new Text('Log out'),
            onPressed: widget.logout
          )
        ]
      )
    );

    if (_onlineUsers != null && _onlineUsers.length > 0) {
      print(_onlineUsers);
      usersWidget = new Column(
        children: _onlineUsers.map((username) {
          return new ListTile(
            leading: new CircleAvatar(
                child: new Text(username[0].toUpperCase())
            ),
            title: new Text(username),
            subtitle: new Text('Last message'),
            onTap: () => _openChat(username),
          );
        }).toList()
      );
    }

    return usersWidget;
  }
}