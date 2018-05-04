import 'dart:io';
import 'dart:async';
import 'util.dart';

class Server {
  String _host;
  int _port;
  Socket _socket;
  StreamSubscription _inputStream;

  Function _onData = () {};
  Function _onError = () {};

  Function onInvitation = (String username) {};
  Function onMessage = (String message, String username) {};
  Function onEncryptedMessage = (String encryptedMessage) {};
  Function onAudio = (List<int> audioBytes, String username) {};

  bool busy = false;
  String receivedData = '';

  String get host => _host;

  int get port => _port;

  Server(String host, int port) {
    this._host = host;
    this._port = port;
  }

  Future<void> connect() async {
    if (_socket?.remoteAddress != null) {
      log('Socket is already open.');
      return null;
    }

    try {
      _socket = await Socket.connect(_host, _port);
      log(_port.toString());
      log('Socket opened successfully.');
      _inputStream = _socket.listen((event) => _handleSocketData(event));

      _socket.done.then((_) {
        log('Socket has been closed.');
        _inputStream.cancel();
      }).catchError((error) {
        logError('An error has been occurred in the socket.');
        logError(error);
      });
    } catch (exception) {
      logError('Error while opening socket.');
      logError(exception.toString());

      throw(exception);
    }
  }

  void disconnect({Function callback}) {
    if (_socket == null) {
      log('Connection was not opened. Nothing to close.');
      return;
    }

    try {
      _sendString('DISCONNECT', onData: (response) async {
        if (response.contains('Goodbye')) {
          await _socket.close();
          if (callback != null) callback();
        }
      });
    } catch (exception) {
      logError('Error while closing socket.');
      logError(exception.toString());
      throw(exception);
    }
  }

  void register(String username, Function onFinish, {Function onError}) {
    // TODO: Check if connected
    try {
      _sendString('REGISTER $username', onData: (response) {
        if (!response.contains('Welcome ')) {
          logError(response);
          if (onError != null) onError(response);
          return;
        }

        log('Registered as "$username".');
        onFinish(response);
      }, onError: onError);
    } catch (exception) {
      logError("Couldn't register user.");
      throw(exception);
    }
  }

  void getUsers(Function callback) {
    // TODO: Callbacks to Futures
    // TODO: Log exception in sendString
    _sendString('WHO', onData: callback);
  }

  void sendMessage(String message, String username, Function callback,
      { int channelMode }) {
    String channelModeString = channelMode != null ? channelMode.toString() : '';
    _sendString('${channelModeString}MSG', data: '$username $message', onData: callback);
    log('Message sent to $username: $message');
  }

  void sendMessageBitArray(String message, String username, int channelMode,
      Function callback) {
    // TODO: Types in immediate function definitions
    String binaryMessage = message.codeUnits.map((int strInt) =>
        '0${strInt.toRadixString(2)}').join();

    _sendString('${channelMode}MSG $username', data: binaryMessage, onData: callback);
  }

  void sendData(List<int> bytes, String username, int channelMode, Function callback) {
    String binaryMessage = bytes.map((int strInt) =>
        '0${strInt.toRadixString(2)}').join();

    _sendString('${channelMode}MSG $username', data: binaryMessage, onData: callback);
  }

  void inviteUser(String username, {Function callback}) {
    _sendString('INVITE $username', onData: callback);
    log('Invited $username');
  }

  void acceptInvitation(String username) {
    _sendString('ACCEPT $username');
    log('Invitation from $username has been accepted.');
  }

  void _handleSocketData(event) {
    String response = new String.fromCharCodes(event);

    if (response.contains('ERROR')) {
      RegExp errorRegex = new RegExp(r'ERROR\s*(.*)');
      Match errorMatch = errorRegex.firstMatch(response);

      logError(errorMatch.group(1));
      if (_onError != null) _onError(errorMatch.group(1));
    } else if (response.contains('INVITE')) {
      RegExp invitationRegex = new RegExp(r'INVITE\s*(.*)');
      Match invitationMatch = invitationRegex.firstMatch(response);

      log('Chat invitation received from ${invitationMatch.group(1)}.');
      if (onInvitation != null) onInvitation(invitationMatch.group(1));
    } else if (response.contains('via channel'))  {
      RegExp messageRegex = new RegExp(r'(.*) \(via channel\): ([01]*)');
      Iterable<Match> messageMatches = messageRegex.allMatches(response);

      String data = messageMatches.fold('', (accumulator, messageMatch) =>
        accumulator + messageMatch.group(2));
      String username = messageMatches.elementAt(messageMatches.length - 1).group(1);
      String message = parseBinaryString(data);

      log('Data message received from $username (via channel).');

      if (message.substring(0, 4) == 'RIFF') {
        onAudio(message.codeUnits, username);
      } else {
        onMessage(message, username);
      }
    } else if (response.contains('MSG')) {
      RegExp messageRegex = new RegExp(r'MSG\s*([^\s]*)\s*(.*)');
      Match messageMatch = messageRegex.firstMatch(response);

      String username = messageMatch.group(1);
      String message = messageMatch.group(2);

      log('Message received from $username: $message');
      onMessage(message, username);
    } else {
      try {
        onEncryptedMessage(parseBinaryString(response));
      } catch (_) {
        log('Message received: $response');
        _onData(response);
      }
    }
  }

  void _sendString(String command, {String data, Function onData, Function onError}) {
    if (_socket == null) {
      logError('Socket is not open.');
      throw new StateError('Socket is not open.');
    }

    if (onData != null) _onData = onData;
    if (onError != null) _onError = onError;

    if (data == null) {
      _socket.write(command);
    } else {
//      var fromByte = new StreamTransformer<List<int>, String>.fromHandlers(
//          handleData: (List<int> data, EventSink<String> sink) {
//        sink.add('${data.buffer.toString()}');
//      });
//
//      _socket.transform(fromByte);
      RegExp byteRegex = new RegExp(r'.{1,1024}');
      Iterable<Match> chunkMatches = byteRegex.allMatches(data);

      if (chunkMatches.length > 300) {
        logError('File is too large to be sent.');
        return;
      }

      chunkMatches.toList().asMap().forEach((int index, Match chunkMatch) {
        String chunk = '$command ${chunkMatch.group(0)}';
        _socket.write(chunk);

        log('Sending data: $index/${chunkMatches.length}');
        sleep(new Duration(milliseconds: 100));
      });
    }
  }
}