import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Apis/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Models/message.dart';
import '../helper/my_date_util.dart';
import '../main.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showModalSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: widget.message.type == Type.image
                ? null
                : const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                color: const Color.fromARGB(255, 221, 245, 255),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ?

                // show text
                Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  )

                // show image

                : ClipRRect(
                    borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(
                        Icons.image,
                        size: 70,
                      )),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
            MyDateUtil.getFormattedtime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        )
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              widget.message.read.isNotEmpty
                  ? const Icon(
                      Icons.done_all_rounded,
                      size: 20,
                      color: Colors.blue,
                    )
                  : const Icon(
                      Icons.done_all_rounded,
                      size: 20,
                    ),
              const SizedBox(
                width: 2,
              ),
              const SizedBox(
                width: 2,
              ),
              Text(
                MyDateUtil.getFormattedtime(
                    context: context, time: widget.message.sent),
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
        Flexible(
          child: Container(
            padding: widget.message.type == Type.image
                ? null
                : const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                color: const Color.fromARGB(255, 203, 247, 204),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type == Type.text
                ?

                // show text
                Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  )

                // show image

                : ClipRRect(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(
                        Icons.image,
                        size: 70,
                      )),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showModalSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              // black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * 0.015, horizontal: mq.width * 0.4),
                decoration: const BoxDecoration(color: Colors.grey),
              ),

              // Copy item
              widget.message.type == Type.text
                  ? _OptiopnItem(
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.blue,
                      ),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          // for hiding bottom sheet
                          Navigator.pop(context);

                          // for showing snakbar
                          Dialogs.showSnackBar(context, "Text Copied!");

                          log("Text copied");
                        }).onError((error, stackTrace) {
                          log("Error on copying text");
                        });
                      })
                  : _OptiopnItem(
                      icon: const Icon(
                        Icons.download,
                        color: Colors.blue,
                      ),
                      name: 'Save image',
                      onTap: () {}),

              // divider
              Divider(
                color: Colors.black54,
                indent: mq.width * 0.05,
                endIndent: mq.width * 0.05,
              ),

              if (widget.message.type == Type.text && isMe)
                // edit item
                _OptiopnItem(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),
                    name: 'Edit Message',
                    onTap: () {}),

              // delete item
              if (isMe)
                _OptiopnItem(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    name: 'Delete Message',
                    onTap: () async {
                      await APIs.deleteMessage(widget.message).then((value) {
                        // for hiding botom sheet
                        Navigator.pop(context);

                        // for showing snakbar
                        Dialogs.showSnackBar(context, "Message Deleted");
                      });
                    }),

              // divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  indent: mq.width * 0.05,
                  endIndent: mq.width * 0.05,
                ),

              // sent item
              _OptiopnItem(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.blue,
                  ),
                  name:
                      'Sent at: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),

              // read item
              _OptiopnItem(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.green,
                  ),
                  name: widget.message.read.isEmpty
                      ? 'Not read yet!'
                      : 'Read at: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        });
  }
}

class _OptiopnItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptiopnItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * 0.05,
            top: mq.height * 0.015,
            bottom: mq.height * 0.015),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '    $name',
                style: const TextStyle(
                    fontSize: 16, color: Colors.black54, letterSpacing: 0.5),
              ),
            )
          ],
        ),
      ),
    );
  }
}
