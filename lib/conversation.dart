class Conversation {
  bool isActive;
  bool isInForeground;
  String partnerUsername;

  List<Message> messages;

  Conversation(String partnerUsername) {
    this.partnerUsername = partnerUsername;

    isActive = false;
    isInForeground = false;
    messages = new List<Message>();
  }
}

class Message {
  final bool isFromUser;
  final String text;

  DateTime _sendTime;
  bool _isSent;

  DateTime get sendTime => _sendTime;
  bool get isSent => _isSent;

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