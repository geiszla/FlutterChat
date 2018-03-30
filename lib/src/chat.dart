import 'package:flutter/material.dart';

import '../conversation.dart';
import '../user.dart';

class Chat extends StatelessWidget {
  Chat({this.user, this.conversation});

  final User user;
  final Conversation conversation;

  @override
  build(BuildContext context) {
    List<Widget> messageWidgets = conversation.messages.map((message) =>
      new ChatMessage(message: message, currentUser: user)
    ).toList().reversed.toList();

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('${conversation.partnerUsername} (online)')
      ),
      body: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Column(
          children: <Widget> [
            new Flexible(
              child: new ListView.builder(
                padding: new EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: (_, int index) => messageWidgets[index],
                itemCount: messageWidgets.length,
              ),
            ),
            new Divider(height: 1.0),
            new Row(
              children: <Widget>[
                new Flexible(
                  child: new Container(
                    margin: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                    child: new TextField(
                      decoration: new InputDecoration.collapsed(
                        hintText: "Send a message"),
                    ),
                  )
                ),
                new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: () {}
                  )
                )
              ]
            )
          ]
        )
      )
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.message, this.currentUser});

  final Message message;
  final User currentUser;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color backgroundColor = message.isFromUser ? theme.primaryColor : null;
    TextStyle textStyle = message.isFromUser ? theme.accentTextTheme.body1
        : null;
    Alignment messageAlignment = message.isFromUser ? Alignment.centerRight
        : Alignment.centerLeft;

    final EdgeInsetsGeometry ownMargin = new EdgeInsets.fromLTRB(100.0, 0.0,
        10.0, 0.0);
    final EdgeInsetsGeometry partnerMargin = new EdgeInsets.fromLTRB(10.0, 0.0,
        100.0, 0.0);

    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: new Container(
        alignment: messageAlignment,
        margin: message.isFromUser ? ownMargin : partnerMargin,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Card(
                color: backgroundColor,
                child: new Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 8.0
                  ),
                  child: new Text(message.text, style: textStyle)
                )
              )
          ]
        )
      )
    );
  }
}