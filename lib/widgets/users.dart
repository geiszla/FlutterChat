import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import '../server.dart';
import '../user.dart';
import '../util.dart';
import '../conversation.dart';

import 'package:flutterchat/widgets/chat.dart';
import 'package:flutterchat/widgets/loading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show basename, dirname;

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

  static const String _encryptionSignature = 'Sent by BarryBot, School of Computer'
      ' Science, The University of Manchester';
  String _decryptionUsername = '';
  String _previousXorResult = '';


  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  Future<Null> _getUsers() async {
    Completer<Null> completer = new Completer<Null>();

    widget.server.getUsers((response) {
      RegExp listRegex = new RegExp(r"WHO\s*\[((?:'[^']*',?\s*)*)\]");
      Match listMatch = listRegex.firstMatch(response);

      if (listMatch == null) return;

      // TODO: Simpler quote removal
      List<String> matchList = listMatch[1].split(',');
      RegExp nameRegex = new RegExp(r"'(.*)'");
      Iterable<String> usernames = matchList.map((listElement) {
        Match nameMatch = nameRegex.firstMatch(listElement);
        return nameMatch[1];
      }).where((username) => username != widget.user.name);

      completer.complete();
      setState(() => _onlineUsers = usernames.toList());
      log('Online users: ${usernames.length > 0 ? usernames : '<none>'}');
    });

    return completer.future;
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
            sendMessage: _handleMessageSend,
          );
        }
      )
    );
  }

  Future<String> _fixAudio(String filePath) async {
    File inputFile = new File(filePath);
    List<int> audioBytes = new List<int>.from((await inputFile.readAsBytes()));

    int audioStartIndex = 44;
    List<int> audioSamples = bytesToInt16List(audioBytes, offset: audioStartIndex);

    // Replace lost packets with previous or next packet
    const int packetSize = 200;
    List<int> previousPacket;
    for (int i = 0; i < audioSamples.length; i += packetSize) {
      int packetEnd = i + packetSize;
      int nextPacketEnd = packetEnd + packetSize;
      List<int> currentPacket = audioSamples.sublist(i, i + packetSize);

      if (currentPacket.indexWhere((byte) => byte != 0) == -1){
        if (previousPacket != null) {
          audioSamples.replaceRange(i, packetEnd, previousPacket);
        } else {
          List<int> nextPacket = audioSamples.sublist(packetEnd, nextPacketEnd);
          audioSamples.replaceRange(packetEnd, nextPacketEnd, nextPacket);
        }
      }

      previousPacket = currentPacket;
    }

    // Smooth out bit errors
    for (int i = 1; i < audioSamples.length - 1; i++) {
      if ((audioSamples[i] - audioSamples[i - 1]).abs() > 16000) {
        audioSamples[i] = ((audioSamples[i - 1] + audioSamples[i + 1]) / 2).round();
      }
    }

    List<int> packetBytes = new List<int>();
    for (int i = 0; i < audioSamples.length; i++) {
      if (audioSamples[i] < 0) audioSamples[i] += 65536;

      int byte1 = audioSamples[i] >> 8;
      int byte2 = audioSamples[i] - (byte1 << 8);

      packetBytes.add(byte2);
      packetBytes.add(byte1);
    }
    audioBytes.replaceRange(audioStartIndex, audioBytes.length, packetBytes);

    File outputFile = new File('${dirname(inputFile.path)}/fixed${basename(inputFile.path)}');
    await outputFile.writeAsBytes(audioBytes);

    return outputFile.path;
  }

  void _decryptAndAddMessage(String message, String key, Conversation conversation) {
    String decryptedMessage = xorMessages(message, key);
    setState(() => conversation.messages.add(
      new Message('Decrypted message: $decryptedMessage', isFromUser: false)
    ));
    currentChatState.setState(() {});
  }

  void _sendMessage(String message, String username, int channelMode,
      MessageMode messageMode, Function callback) {
    switch (messageMode) {
      case MessageMode.binary:
        widget.server.sendMessageBitArray(message, username, channelMode, callback);
        break;
      case MessageMode.command:
        if (message.toLowerCase() == 'encrypt') {
          widget.server.onEncryptedMessage = (message) {
            Conversation currentConversation = _conversations[_decryptionUsername];

            String currentDecryptionKey = currentConversation.decryptionKey;
            if (currentDecryptionKey != null) {
              _decryptAndAddMessage(message, currentDecryptionKey, currentConversation);
              return;
            } else {
              setState(() => currentConversation.messages.add(
                new Message('Encrypted message: $message', isFromUser: false)
              ));
              currentChatState.setState(() {});
            }

            if (_previousXorResult != '') {
              String xorResult = xorMessages(message, _previousXorResult);
              String key = xorMessages(
                  xorMessages(_previousXorResult, _encryptionSignature),
                  xorResult
              );
              _showDecryption(context, _decryptionUsername, message, xorResult, key);

              _previousXorResult = xorMessages(_encryptionSignature, message);
            } else {
              _previousXorResult = xorMessages(_encryptionSignature, message);
              _sendMessage('ENCRYPT', username, 0, MessageMode.command, () {});
            }
          };
          _decryptionUsername = username;
        }

        widget.server.sendMessage(message, username, callback, channelMode: channelMode);
        break;
      default:
        widget.server.sendMessage(message, username, callback);
    }
  }

  Future<void> _handleMessageSend(String message, String username, { bool isAudio }) async {
    Conversation currentConversation = _conversations[username];
    setState(() {
      currentConversation.messages.add(
        new Message(message, isFromUser: true, isAudio: isAudio)
      );
      currentChatState?.setState(() {});
    });

    int channelMode = currentConversation.channelMode;
    MessageMode messageMode = currentConversation.messageMode;
    if (!currentConversation.isActive) {
      widget.server.inviteUser(username,
          callback: (response) => _activateConversation(username));
    } else {
      if (isAudio) {
        List<int> audioBytes = await (new File(message)).readAsBytes();
        widget.server.sendData(audioBytes, username, channelMode,
          (response) => currentConversation.messages.last.changeToSent());
      } else {
        _sendMessage(message, username, channelMode, messageMode,
          (response) => currentConversation.messages.last.changeToSent());
      }
    }

    if (isAudio && message.contains('sample')) {
      String fixedAudioFileName = await _fixAudio(message);
      setState(() {
        _conversations[username].messages.add(
          new Message(fixedAudioFileName, isFromUser: true, isAudio: true)
        );
      });
      currentChatState?.setState(() {});
    }
  }

  void _activateConversation(username) {
    if (_conversations[username] == null) {
      _conversations[username] = new Conversation(username);
    }

    Conversation conversation = _conversations[username];
    conversation.isActive = true;

    int channelMode = conversation.channelMode;
    MessageMode messageMode = conversation.messageMode;
    conversation.messages.forEach((message) async {
      if (message.isAudio) {
        List<int> audioBytes = await (new File(message.text)).readAsBytes();
        widget.server.sendData(audioBytes, username, channelMode,
          (response) => conversation.messages.last.changeToSent());
      } else {
        _sendMessage(message.text, username, channelMode, messageMode,
          (response) => message.changeToSent());
      }
    });
  }

  void _showDecryption(BuildContext context, String username,
      String previousMessage, String decryptedMessage, String key) {
    showDialog(builder: (BuildContext context) {
      AlertDialog infoAlert = new AlertDialog(
        title: const Text('Does this message seem decrypted?'),
        content: new Text(decryptedMessage),
        actions: <Widget>[
          new FlatButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.pop(context);
              _sendMessage('ENCRYPT', username, 0, MessageMode.command, () {});
            }
          ),
          new FlatButton(
            child: const Text('Yes'),
            onPressed: () {
              setState(() {
                Conversation currentConversation = _conversations[username];
                _decryptAndAddMessage(previousMessage, key, currentConversation);
                currentConversation.messages.add(
                    new Message('Decrypted message: $decryptedMessage', isFromUser: false)
                );
                _conversations[username].decryptionKey = key;
              });

              currentChatState.setState(() {});
              Navigator.pop(context);
            }
          )
        ]
      );

      return infoAlert;
    }, context: context);
  }

  @override
  void initState() {
    super.initState();
    _getUsers();

    widget.server.onInvitation = (String username) {
      widget.server.acceptInvitation(username);
      _activateConversation(username);
    };

    widget.server.onMessage = (String message, String username) {
      setState(() {
        _conversations[username].messages.add(
            new Message(message, isFromUser: false)
        );
      });
      currentChatState?.setState(() {});
    };

    widget.server.onAudio = (List<int> audioBytes, String username) async {
      Directory tempDirectory = await getTemporaryDirectory();
      int time = new DateTime.now().millisecondsSinceEpoch;
      File audioFile = new File('$tempDirectory/$time.wav');
      await audioFile.writeAsBytes(audioBytes);

      setState(() {
        _conversations[username].messages.add(
          new Message(audioFile.path, isFromUser: false, isAudio: true)
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
      List<Widget> userWidgets = _onlineUsers.map((username) {
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
      }).toList();

      usersWidget = new RefreshIndicator(
        onRefresh: _getUsers,
        child: new ListView.builder(
          itemBuilder: (_, int index) => userWidgets[index],
          itemCount: userWidgets.length,
        )
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