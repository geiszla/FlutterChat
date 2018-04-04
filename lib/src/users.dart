import 'package:flutter/material.dart';

import '../server.dart';
import '../user.dart';
import '../util.dart';
import '../conversation.dart';

import 'chat.dart';
import 'loading.dart';

class Users extends StatefulWidget {
  final User user;
  final Server server;

  Users({this.user, this.server});

  @override
  UsersState createState() => new UsersState();
}

class UsersState extends State<Users> {
  List<String> _onlineUsers;
  Map<String, Conversation> _conversations = new Map<String, Conversation>();

  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  void _getUsers() {
    setState(() => _onlineUsers = null);

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
    if (_conversations[username] == null) {
      _conversations[username] = new Conversation(username);
    }

    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Chat(
            user: widget.user,
            conversation: _conversations[username],
            sendMessage: _sendMessage,
          );
        }
      )
    );
  }

  void _sendMessage(String message, String username) {
    Conversation currentConversation = _conversations[username];
    setState(() {
      currentConversation.messages.add(
        new Message(text: message, isFromUser: true)
      );
      currentChatState?.setState(() {});
    });

    if (!currentConversation.isActive) {
      widget.server.inviteUser(username,
          callback: (response) => _activateConversation(username));
    } else {
      widget.server.sendMessage(message, username,
        (response) => currentConversation.messages.last.changeToSent());
    }
  }

  void _activateConversation(username) {
    if (_conversations[username] == null) {
      _conversations[username] = new Conversation(username);
    }

    _conversations[username].isActive = true;
    _conversations[username].messages.forEach((message) {
      widget.server.sendMessage(message.text, username,
              (response) => message.changeToSent());
    });
  }

  @override
  void initState() {
    super.initState();
    _getUsers();

    widget.server.onInvitation = (username) {
      widget.server.acceptInvitation(username);
      _activateConversation(username);
    };
    widget.server.onMessage = (message, username) {
      setState(() {
        _conversations[username].messages.add(
            new Message(text: message, isFromUser: false)
        );
      });
      currentChatState?.setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget usersWidget;

    if (_onlineUsers == null) {
      return new Loading(text: 'Looking for online users...');
    }

    if (_onlineUsers.length > 0) {
      // TODO: Change user Column to ListView
      usersWidget = new Column(
        children: _onlineUsers.map((username) {
          Conversation currentConversation = _conversations[username];

          String lastMessageString = '';
          if (currentConversation != null) {
            int messageCount = currentConversation.messages.length;
            if (messageCount > 0) {
              Message lastMessage = currentConversation.messages[messageCount - 1];
              lastMessageString = lastMessage.isFromUser ? 'You: ' : '';
              lastMessageString += lastMessage.text;
            }
          }

          return new ListTile(
            leading: new CircleAvatar(
                child: new Text(username[0].toUpperCase())
            ),
            title: new Text(username),
            subtitle: new Text(lastMessageString),
            onTap: () => _openChat(username),
          );
        }).toList()
      );
    } else {
      usersWidget = new Center(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text('No online users.', style: _biggerFont),
            const SizedBox(height: 50.0),
            new RaisedButton(
              child: const Text('Refresh'),
              onPressed: _getUsers
            )
          ]
        )
      );
    }

    return usersWidget;
  }
}