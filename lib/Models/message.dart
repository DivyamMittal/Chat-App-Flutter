class Message {
  Message({
    required this.fromId,
    required this.toId,
    required this.msg,
    required this.type,
    required this.read,
    required this.sent,
  });
  late final String fromId;
  late final String toId;
  late final String msg;
  late final Type type;
  late final String read;
  late final String sent;

  Message.fromJson(Map<String, dynamic> json) {
    fromId = json['fromId'].toString();
    toId = json['toId'].toString();
    msg = json['msg'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    read = json['read'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fromId'] = fromId;
    data['toId'] = toId;
    data['msg'] = msg;
    data['type'] = type.name;
    data['read'] = read;
    data['sent'] = sent;
    return data;
  }
}

enum Type { text, image }
