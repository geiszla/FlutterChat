import 'dart:io';
import 'dart:async';
import 'util.dart';

class Server {
  String _host;
  int _port;
  Socket _socket;
  StreamSubscription _inputStream;

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
      log('Socket opened successfully.');
      _inputStream = _socket.listen((event) => _logStream(event));

      _socket.done.then((_) {
        log('Socket has been closed.');
        _inputStream.cancel();
      }).catchError((error) {
        logError('An error has been occurred in the socket.');
        logError(error);
      });
    } catch(exception) {
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
      _sendString('DISCONNECT');
      _inputStream.onData((event) => _logStream(event,
        callback: (response) async {
          if (response.contains('Goodbye')) {
            await _socket.close();
            if (callback != null) callback();
          }
        }
      ));
    } catch(exception) {
      logError('Error while closing socket.');
      logError(exception.toString());
      throw(exception);
    }
  }

  void register(String username) {
    try {
      _sendString('REGISTER $username');
      log('Registered as "$username".');
    } catch (exception) {
      logError("Couldn't send register command.");
      throw(exception);
    }
  }

  void getUsers(Function callback) {
    try {
      _sendString('WHO');
      _inputStream.onData((event) => _logStream(event, callback: callback));
    } catch (exception) {
      throw(exception);
    }
  }

  void _logStream(event, {Function callback}) {
    String response = new String.fromCharCodes(event);
    log('Message received: $response');
    if (callback != null) callback(response);
  }

  void _sendString(String data) {
    if (_socket == null) {
      logError('Socket is not open.');
      throw new StateError('Socket is not open.');
    }

    _socket.write(data);
  }
}