enum MessageMode {
  text, binary, command
}

const List<String> MessageModeStrings = const ['ABC', '010', '! ! !'];

class Conversation {
  // TODO: Public variables
  bool isActive;
  bool isInForeground;
  String partnerUsername;

  int channelMode = 0;
  MessageMode messageMode = MessageMode.text;

  String decryptionKey;

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
  bool isAudio;
  final String text;

  Message(this.text, {this.isFromUser, this.isAudio}) {
    if (isAudio == null) {
      this.isAudio = false;
    }
  }

  void changeToSent() {
    _sendTime = new DateTime.now();
    _isSent = true;
  }

  void changeToUnsent() {
    _sendTime = null;
    _isSent = false;
  }
}