enum UserState {
  connecting, connected, disconnecting, disconnected, registered, conversation
}

class User {
  User(String name) {
    _name = name;
    state = UserState.disconnected;
  }

  String _name;
  UserState state;

  String get name => _name;
}