class ChatUser {
  ChatUser({
    required this.id,
    required this.image,
    required this.lastActive,
    required this.name,
    required this.email,
    required this.isOnline,
    required this.pushToken,
    required this.createdAt,
    required this.about,
  });

  late String id;
  late String image;
  late String lastActive;
  late String name;
  late String email;
  late bool isOnline;
  late String pushToken;
  late String createdAt;
  late String about;

  ChatUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'] ?? '';
    lastActive = json['last_active'] ?? '';
    name = json['name'] ?? '';
    email = json['email'] ?? '';
    isOnline = json['is_online'] ?? '';
    pushToken = json['push_token'] ?? '';
    createdAt = json['created_at'] ?? '';
    about = json['about'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['last_active'] = lastActive;
    data['name'] = name;
    data['email'] = email;
    data['is_online'] = isOnline;
    data['push_token'] = pushToken;
    data['created_at'] = createdAt;
    data['about'] = about;
    return data;
  }
}
