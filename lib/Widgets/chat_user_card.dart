import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Apis/apis.dart';
import 'package:chat_app/Models/chat_user.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/message.dart';
import '../Screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});
  final ChatUser user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info ( if null --> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
            stream: APIs.getlastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) {
                _message = list[0];
              }

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    width: 41,
                    height: 41,
                    imageUrl: widget.user.image,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),
                title: Text(widget.user.name),
                subtitle: _message != null && _message!.type == Type.image
                    ? Row(
                        children: [
                          Icon(
                            Icons.image,
                            size: 18,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text("Photo"),
                          )
                        ],
                      )
                    : Text(
                        _message != null ? _message!.msg : widget.user.about,
                        maxLines: 1,
                      ),
                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                            _message!.fromId != APIs.user.uid
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: Colors.green.shade500,
                                borderRadius: BorderRadius.circular(20)),
                          )
                        : Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: TextStyle(color: Colors.black54),
                          ),
              );
            },
          )),
    );
  }
}
