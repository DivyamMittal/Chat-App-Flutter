import 'dart:developer';
import 'dart:io';

import 'package:chat_app/Models/chat_user.dart';
import 'package:chat_app/Models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static late ChatUser me;

  // to return current user
  static User get user => auth.currentUser!;

  // for checking if user exists
  static Future<bool> userExists() async {
    return (await firestore
            .collection("users")
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //for creating new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using chat Application",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: "");

    return await firestore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return APIs.firestore
        .collection("users")
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for updating data in rpofile page
  static Future<void> updateUserInfo() async {
    await firestore
        .collection("users")
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last; // ext is file extention
    log("extention : $ext");
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {
      log("Data transfered : ${p0.bytesTransferred / 1000} kb");
    });
    me.image = await ref.getDownloadURL();
    await firestore
        .collection("users")
        .doc(user.uid)
        .update({'image': me.image});
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection("users")
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection("users").doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString()
    });
  }

  ///****************** Chat related Code ****************** */

  // for getting all messages of a specific conversation from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMesages(
      ChatUser user) {
    return APIs.firestore
        .collection("chat/${getConversationId(user.id)}/messages/")
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // for getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to sent
    final Message message = Message(
        fromId: user.uid,
        toId: chatUser.id,
        msg: msg,
        type: type,
        read: '',
        sent: time);

    final ref = firestore
        .collection("chat/${getConversationId(chatUser.id)}/messages/");
    await ref.doc(time).set(message.toJson());
  }

  // update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection("chat/${getConversationId(message.fromId)}/messages/")
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getlastMessage(
      ChatUser user) {
    return firestore
        .collection("chat/${getConversationId(user.id)}/messages/")
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatuser, File file) async {
    final ext = file.path.split('.').last; // ext is file extention

    final ref = storage.ref().child(
        'images/${getConversationId(chatuser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {
      log("Data transfered : ${p0.bytesTransferred / 1000} kb");
    });
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatuser, imageUrl, Type.image);
  }
}
