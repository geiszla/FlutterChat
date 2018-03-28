import 'package:flutter/material.dart';

class Chat extends StatelessWidget {
  Chat({this.partnerUsername});

  final String partnerUsername;
  final List<String> _messages = ['message1', 'message2', 'message3'];

  @override
  build(BuildContext context) {
    List<Widget> messageWidgets = _messages.map((message) =>
      new ChatMessage(text: message)
    ).toList().reversed.toList();

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('$partnerUsername (online)')
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
                itemCount: 3,
              ),
            ),
            new Divider(height: 1.0),
            new Row(
              children: <Widget>[
                new Flexible(
                  child: new TextField(
                    decoration: new InputDecoration.collapsed(
                      hintText: "Send a message"),
                  ),
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
  ChatMessage({this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 16.0)
          ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: new Text(text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}