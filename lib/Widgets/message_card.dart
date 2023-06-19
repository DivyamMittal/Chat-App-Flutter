import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Apis/apis.dart';
import 'package:flutter/material.dart';

import '../Models/message.dart';
import '../helper/my_date_util.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
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
}
