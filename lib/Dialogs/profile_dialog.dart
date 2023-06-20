import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Models/chat_user.dart';
import 'package:chat_app/Screens/view_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * 0.6,
        height: mq.height * 0.40,
        child: Stack(children: [
          Column(
            children: [
              SizedBox(
                height: 20,
              ),

              // Profile picture of user
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CachedNetworkImage(
                        width: mq.width * 0.4,
                        height: mq.width * 0.4,
                        // fit: BoxFit.cover,
                        imageUrl: user.image,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                                child: Icon(CupertinoIcons.person)),
                      ),
                    ),
                  ),
                ),
              ),

              // user name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(
                height: 10,
              ),

              // email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  user.email,
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),

          // info material button
          Align(
            alignment: Alignment.topRight,
            child: MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewProfileScreen(user: user)));
              },
              minWidth: 0,
              padding: const EdgeInsets.all(0),
              shape: const CircleBorder(),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Colors.blue,
              ),
            ),
          )
        ]),
      ),
    );
  }
}
