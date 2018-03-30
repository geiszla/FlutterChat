enum UserState {
  connecting, connected, disconnecting, disconnected, registered, conversation
}

const List<String> _stateStrings = const ['Connecting...', 'Connected',
  'Disconnecting...', 'Disconnected', 'Registered', 'In conversation'];

class User {
  User(String name) {
    _name = name;
    state = UserState.disconnected;
  }

  String _name;
  UserState state;

  String get name => _name;
  String get stateString {
    return _stateStrings[state.index];
  }

  bool isEqual(User otherUser) {
    return _name == otherUser.name;
  }
}