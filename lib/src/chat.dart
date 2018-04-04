import 'package:flutter/material.dart';

import '../conversation.dart';
import '../user.dart';

ChatState currentChatState;

class Chat extends StatefulWidget {
  final User user;
  final Conversation conversation;
  final Function sendMessage;

  // TODO: [3] Required arguments
  Chat({this.user, this.conversation, this.sendMessage});

  @override
  ChatState createState() {
    currentChatState = new ChatState();
    return currentChatState;
  }
}

class ChatState extends State<Chat> {
  String _inputText = '';
  TextEditingController _inputController = new TextEditingController();

  void _sendMessage() {
    widget.sendMessage(_inputText, widget.conversation.partnerUsername);
    _inputController.clear();
  }

  @override
  build(BuildContext context) {
    Widget chatContent;
    if (widget.conversation.messages.length == 0) {
      chatContent = new Center(
        child: new Text(
          'Send a message to start a conversation.',
          style: const TextStyle(fontSize: 16.0)
        )
      );
    } else {
      Message lastMessage;
      List<Widget> messageWidgets = widget.conversation.messages.map((message) {
        ChatMessage currentWidget = new ChatMessage(message: message,
            lastMessage: lastMessage, currentUser: widget.user);
        lastMessage = message;

        return currentWidget;
      }).toList().reversed.toList();

      chatContent = new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new ListView.builder(
          reverse: true,
          itemBuilder: (_, int index) => messageWidgets[index],
          itemCount: messageWidgets.length,
        )
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('${widget.conversation.partnerUsername} (online)')
      ),
      body: new Column(
        children: <Widget> [
          new Flexible(
            child: chatContent
          ),
          const Divider(height: 1.0),
          new Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: new Row(
              children: <Widget>[
                new Flexible(
                  child: new Container(
                    margin: const EdgeInsets.only(left: 8.0),
                    child: new TextField(
                      onChanged: (text) => setState(() => _inputText = text),
                      controller: _inputController,
                      decoration: const InputDecoration.collapsed(
                        hintText: "Send a message"),
                    ),
                  )
                ),
                new Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: new IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _inputText != '' ? _sendMessage : null
                  )
                )
              ]
            )
          )
        ]
      )
    );
  }
}

class ChatMessage extends StatelessWidget {
  final Message message;
  final Message lastMessage;
  final User currentUser;

  ChatMessage({this.message, this.lastMessage, this.currentUser});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color backgroundColor = message.isFromUser ? theme.primaryColor : null;
    TextStyle textStyle = message.isFromUser ? theme.accentTextTheme.body1
        : null;
    Alignment messageAlignment = message.isFromUser ? Alignment.centerRight
        : Alignment.centerLeft;

    double leftMargin = message.isFromUser ? 100.0 : 20.0;
    double rightMargin = message.isFromUser ? 20.0 : 100.0;

    double topMargin = message.isFromUser == lastMessage?.isFromUser
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