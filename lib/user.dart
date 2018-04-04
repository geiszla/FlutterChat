enum UserState {
  connecting, connected, disconnecting, disconnected, registered, conversation
}

const List<String> _stateStrings = const ['Connecting...', 'Connected',
  'Disconnecting...', 'Disconnected', 'Registered', 'In conversation'];

class User {
  String _name;

  UserState state;
  String get name => _name;
  String get stateString {
    return _stateStrings[state.index];
  }
  bool get isLoggedIn {
    return state != UserState.disconnected && state != UserState.connecting;
  }

  User(String name) {
    _name = name;
    state = UserState.disconnected;
  }

  bool isEqual(User otherUser) {
    return _name == otherUser.name;
  }
}