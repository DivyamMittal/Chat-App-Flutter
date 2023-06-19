import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Models/message.dart';
import 'package:chat_app/Screens/view_profile_screen.dart';
import 'package:chat_app/Widgets/message_card.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Apis/apis.dart';
import '../Models/chat_user.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});
  final ChatUser user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];

  final _textController = TextEditingController();

  bool _showEmoji = false;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(255, 219, 226, 233),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMesages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          // log('Data: ${jsonEncode(data![0].data())}');

                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            log('list is not empty');
                            return ListView.builder(
                                reverse: true,
                                itemCount: _list.length,
                                padding: const EdgeInsets.only(top: 10),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(message: _list[index]);
                                });
                          } else {
                            log('list is empty');
                            return const Center(
                              child: Text(
                                "Say Hi! 👋",
                                style: TextStyle(fontSize: 18),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),

                // progress indicator fpor showing uploading
                if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )),

                // for showing the input field bar
                _chatinput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * 0.37,
                    child: EmojiPicker(
                      textEditingController:
                          _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                      config: Config(
                        bgColor: const Color.fromARGB(255, 219, 226, 233),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isAndroid ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(CupertinoIcons.back)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    width: 41,
                    height: 41,
                    imageUrl:
                        list.isNotEmpty ? list[0].image : widget.user.image,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: list[0].lastActive)
                          : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user.lastActive),
                      style: TextStyle(fontSize: 13),
                    )
                  ],
                )
              ],
            );
          },
        ));
  }

  Widget _chatinput() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.white70,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.grey.shade700,
                      )),
                  Expanded(
                      child: TextField(
                    onTap: () {
                      setState(() {
                        if (_showEmoji) _showEmoji = !_showEmoji;
                      });
                    },
                    controller: _textController,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type message here...'),
                    maxLines: 6,
                    minLines: 1,
                  )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Picking multiple images.
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 80);

                        // uploading and sending image one by one
                        for (var i in images) {
                          log('Image path:  ${i.path}');
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: Colors.grey.shade700,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);

                        if (image != null) {
                          log('Image path: ${image.path}');
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.grey.shade700,
                      )),
                  const SizedBox(
                    width: 4,
                  )
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text, Type.text);
                _textController.text = '';
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 7),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
