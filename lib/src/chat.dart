import 'package:flutter/material.dart';

import '../conversation.dart';
import '../user.dart';

class Chat extends StatefulWidget {
  Chat({this.user, this.conversation});

  final User user;
  final Conversation conversation;

  @override
  ChatState createState() => new ChatState();
}

class ChatState extends State<Chat> {
  String _inputText = '';

  @override
  build(BuildContext context) {
    Message lastMessage;
    List<Widget> messageWidgets = widget.conversation.messages.map((message) {
      ChatMessage currentWidget = new ChatMessage(message: message,
          lastMessage: lastMessage, currentUser: widget.user);
      lastMessage = message;

      return currentWidget;
    }
    ).toList().reversed.toList();

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('${widget.conversation.partnerUsername} (online)')
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
                      onChanged: (text) => setState(() => _inputText = text),
                      decoration: new InputDecoration.collapsed(
                        hintText: "Send a message"),
                    ),
                  )
                ),
                new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: _inputText != '' ? () {} : null
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
  ChatMessage({this.message, this.lastMessage, this.currentUser});

  final Message message;
  final Message lastMessage;
  final User currentUser;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color backgroundColor = message.isFromUser ? theme.primaryColor : null;
    TextStyle textStyle = message.isFromUser ? theme.accentTextTheme.body1
        : null;
    Alignment messageAlignment = message.isFromUser ? Alignment.centerRight
        : Alignment.centerLeft;

    final double leftMargin = message.isFromUser ? 100.0 : 10.0;
    final double rightMargin = message.isFromUser ? 10.0 : 100.0;

    final double topMargin = message.isFromUser == lastMessage?.isFromUser
        ? 0.0 : 10.0;

    return new Container(
        alignment: messageAlignment,
        margin: new EdgeInsets.fromLTRB(leftMargin, topMargin, rightMargin, 0.0),
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
    );
  }
}