class Conversation {
  // TODO: Public variables
  bool isActive;
  bool isInForeground;
  String partnerUsername;

  final List<Message> messages = new List<Message>();

  Conversation(String partnerUsername) {
    this.partnerUsername = partnerUsername;

    isActive = false;
    isInForeground = false;
  }
}

class Message {
  DateTime _sendTime;
  bool _isSent;

  DateTime get sendTime => _sendTime;
  bool get isSent => _isSent;

  final bool isFromUser;
  final String text;

  Message({this.isFromUser, this.text});

  void changeToSent() {
    _sendTime = new DateTime.now();
    _isSent = true;
  }

  void changeToUnsent() {
    _sendTime = null;
    _isSent = false;
  }
}