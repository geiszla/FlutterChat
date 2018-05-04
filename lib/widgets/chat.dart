import '../conversation.dart';
import '../user.dart';

import './chatMessage.dart';
import './record.dart';
import 'package:flutter/material.dart';

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

  void _sendMessage(String message, bool isAudio) {
    widget.sendMessage(message, widget.conversation.partnerUsername, isAudio: isAudio);

    if (!isAudio) {
      _inputController.clear();
      _inputText = '';
    }
  }

  void _showRecordDialog(BuildContext context) async{
    showDialog(builder: (BuildContext context) {
      return new Record(sendMessage: _sendMessage);
    }, context: context);
  }

  @override
  build(BuildContext context) {
    int channelMode = widget.conversation.channelMode;

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
            lastMessage: lastMessage);
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

    Conversation conversation = widget.conversation;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('${conversation.partnerUsername}'),
        actions: <Widget>[
          new FlatButton(
            child: new Text(MessageModeStrings[conversation.messageMode.index]),
            textColor: Colors.white,
            onPressed: () => setState(() {
              MessageMode messageMode = conversation.messageMode;
              int nextIndex = (messageMode.index + 1) % MessageMode.values.length;
              conversation.messageMode = MessageMode.values[nextIndex];
            })
          ),
          new FlatButton(
            child: new Text('Channel: ${channelMode.toString()}'),
            textColor: Colors.white,
            onPressed: conversation.messageMode == MessageMode.text
              ? null
              : () => setState(() =>
                widget.conversation.channelMode = (channelMode + 1) % 6
            ),
          ),
        ]
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
                  margin: const EdgeInsets.only(left: 4.0),
                  child: new Builder(
                    builder: (context) => new IconButton(
                      icon: const Icon(Icons.music_note),
                      onPressed: conversation.messageMode == MessageMode.binary
                        ? () => _showRecordDialog(context)
                        : null
                    )
                  )
                ),
                new Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: new IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _inputText != ''
                        ? () => _sendMessage(_inputText, false)
                        : null
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
