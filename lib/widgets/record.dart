import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

enum RecordingState {
  idle, recording, processing
}

class Record extends StatefulWidget {
  final Function sendMessage;

  Record({this.sendMessage});

  @override
  RecordState createState() => new RecordState();
}

class RecordState extends State<Record> {
  static const platform = const MethodChannel('flutterchat.mbaxaag2.com/audio');
  static const int recordingLength = 5;

  RecordingState _recordingState = RecordingState.recording;
  int _elapsedSeconds = 0;
  String _filePath;

  void _startTimer() {
    try {
      if (_elapsedSeconds == recordingLength) {
      setState(() => _recordingState = RecordingState.processing);
      } else {
        setState(() => _elapsedSeconds++);
        new Timer(new Duration(seconds: 1), _startTimer);
      }
    } catch(_) {}
  }

  void _startRecording() async {
    try {
      setState(() {
        _recordingState = RecordingState.recording;
        _elapsedSeconds = 0;
      });

      _startTimer();
      String filePath = await platform.invokeMethod('recordAudio',
          { 'length': recordingLength });

      setState(() {
        _filePath = filePath;
        _recordingState = RecordingState.idle;
      });
    } catch(_) {}
  }

  @override
  void initState() {
    super.initState();

    _startRecording();
  }

  @override
  Widget build(BuildContext context) {
    String title;
    switch (_recordingState) {
      case RecordingState.idle:
        title = 'Recording complete';
        break;
      case RecordingState.recording:
        title = 'Recording... (${recordingLength - _elapsedSeconds}s)';
        break;
      case RecordingState.processing:
        title = 'Processing...';
        break;
    }

    String content = _recordingState != RecordingState.idle
      ? 'Recoding is in progress. Please wait until recording finishes or '
        ' press "Send sample" to send a sample audio.'
      : 'To send the sample audio, press "Send sample", to send the result'
        ' of the recording, press "Send".';

    return new AlertDialog(
        title: new Text(title),
        content: new Text(content),
        actions: <Widget>[
          new FlatButton(
            child: const Text('Cancel'),
            onPressed: () async {
              Navigator.pop(context);
            }
          ),
          new FlatButton(
            child: const Text('Send sample'),
            onPressed: () async {
              String tempDirectoryPath = (await getTemporaryDirectory()).path;
              File file = new File('$tempDirectoryPath/sample.wav');
              await file.writeAsBytes((await rootBundle.load('assets/sample.wav')).buffer.asUint8List());
              widget.sendMessage(file.path, true);
              Navigator.pop(context);
            }
          ),
          new Builder(
            builder: (BuildContext context) => new FlatButton(
              child: const Text('Send'),
              onPressed: _recordingState == RecordingState.idle
                ? () async {
                  widget.sendMessage(_filePath, true);
                  Navigator.pop(context);
                }
                : null
          ))
        ],
      );
  }
}
