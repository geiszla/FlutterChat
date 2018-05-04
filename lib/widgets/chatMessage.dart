import 'dart:io';

import '../conversation.dart';
import '../util.dart';

import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';

// TODO: UTF-8 messages
class ChatMessage extends StatelessWidget {
  final Message message;
  final Message lastMessage;

  ChatMessage({this.message, this.lastMessage});

  AudioPlayer _audioPlayer;
  static const platform = const MethodChannel('flutterchat.mbaxaag2.com/audio');

  void _playAudio(BuildContext context) async {
    File file = new File(message.text);

    _audioPlayer = new AudioPlayer();
    _audioPlayer.play(file.path, isLocal: true);
    showDialog(builder: (BuildContext context) {
      return new AlertDialog(
        title: new Text('Playing audio: "${basename(file.path)}"'),
        actions: <Widget>[
          new FlatButton(
            child: const Text('12 kHz'),
            onPressed: () async {
              if (_audioPlayer != null) {
                _audioPlayer.stop();
                _audioPlayer = null;
              }

              List<int> audioBytes = await file.readAsBytes();
              List<int> audioSamples = bytesToInt16List(audioBytes, offset: 44);
              int firstDataIndex = audioSamples.indexWhere((sample) => sample != 0);

              await platform.invokeMethod('playBytes', {
                'bytes': audioSamples,
                'samplingFrequency': 12000
              });
            }
          ),
          new FlatButton(
            child: const Text('Close'),
            onPressed: () async {
              if (_audioPlayer != null) {
                _audioPlayer.stop();
                _audioPlayer = null;
              }

              await platform.invokeMethod('stopPlayback');
              Navigator.pop(context);
            }
          ),
          new FlatButton(
            child: const Text('Pause'),
            onPressed: () async {
              if (_audioPlayer != null) _audioPlayer.pause();
              await platform.invokeMethod('pausePlayback');
            }
          ),
          new FlatButton(
              child: const Text('Play'),
              onPressed: () => _audioPlayer.play(file.path, isLocal: true)
          )
        ],
      );
    }, context: context);
  }

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

    Widget messageContent = message.isAudio
        ? new Builder(
        builder: (BuildContext context) {
          return new Column(
            children: <Widget>[
              new IconButton(
                icon: const Icon(Icons.music_note),
                onPressed: () => _playAudio(context)
              ),
              new Text(basename(File(message.text).path))
            ]
          );
        })
        : new Text(message.text, style: textStyle);

    return new Container(
        alignment: messageAlignment,
        margin: new EdgeInsets.fromLTRB(
            leftMargin, topMargin, rightMargin, 0.0),
        child: new Card(
            color: backgroundColor,
            child: new Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 8.0
                ),
                child: messageContent
            )
        )
    );
  }
}