import 'dart:io';
import 'dart:async';
import 'util.dart';

class Server {
  String _host;
  int _port;
  Socket _socket;

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
      _socket.listen((event) {
        String response = new String.fromCharCodes(event);
        log('Message received: $response');
      });

      _socket.done.then((_) {
        log("Socket has been closed.");
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

  Future<void> disconnect() async {
    if (_socket == null) {
      log('Connection was not opened. Nothing to close.');
      return true;
    }

    try {
      _sendString('DISCONNECT');
      await _socket.close();
    } catch(exception) {
      logError('Error while closing socket.');
      logError(exception.toString());
      throw(exception);
    }
  }

  void register(String username) {
    try {
      log('Registered as username.');
      _sendString('REGISTER $username');
    } catch (exception) {
      logError("Couldn't send register command.");
      throw(exception);
    }
  }

  void _sendString(String data) {
    if (_socket == null) {
      logError('Socket is not open.');
      throw new StateError('Socket is not open.');
    }

    _socket.write(data);
  }
}