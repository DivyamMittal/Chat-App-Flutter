import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Models/chat_user.dart';
import 'package:chat_app/helper/Dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../Apis/apis.dart';
import '../Auth/login_screen.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final ChatUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          // leading: IconButton(
          //     icon: Icon(
          //       CupertinoIcons.back,
          //       color: Colors.black,
          //     ),
          //     onPressed: () {}),
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Dialogs.showProgressBar(context);

            // to set inacgtive status on logout
            APIs.updateActiveStatus(false);

            // sign out from app
            await APIs.auth.signOut().then((value) async {
              await GoogleSignIn().signOut().then((value) {
                // for hiding progress dialog
                Navigator.pop(context);

                // for moving to home screen
                Navigator.pop(context);

                APIs.auth = FirebaseAuth.instance;
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              });
            });
          },
          child: const Icon(Icons.exit_to_app),
        ),
        // resizeToAvoidBottomInset: false,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Column(
                  children: [
                    SizedBox(
                      height: mq.height * 0.05,
                    ),
                    Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.file(
                                  File(_image!),
                                  width: mq.width * 0.4,
                                  height: mq.width * 0.4,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                  width: mq.width * 0.4,
                                  height: mq.width * 0.4,
                                  fit: BoxFit.fill,
                                  imageUrl: widget.user.image,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(CupertinoIcons.person)),
                                ),
                              ),
                        Positioned(
                          bottom: -5,
                          right: -5,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              _showModalSheet();
                            },
                            color: Colors.white,
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: mq.height * 0.05,
                    ),
                    Text(
                      widget.user.email,
                      style: const TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: mq.height * 0.03,
                    ),
                    TextFormField(
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      initialValue: widget.user.name,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          hintText: "eg. Divyam ",
                          label: const Text("Name"),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                    SizedBox(
                      height: mq.height * 0.03,
                    ),
                    TextFormField(
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      initialValue: widget.user.about,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.info),
                          hintText: "eg. Felling Happy ",
                          label: const Text("About"),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                    SizedBox(
                      height: mq.height * 0.03,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo();
                          Dialogs.showSnackBar(
                              context, 'Profile Updated Successfully');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder()),
                      child: const Text(
                        "Update",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showModalSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: mq.height * 0.03, bottom: mq.height * 0.03),
            children: [
              const Text(
                "Profile Photo",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);

                      if (image != null) {
                        log('Image path: ${image.path}');
                        setState(() {
                          _image = image.path;
                        });

                        APIs.updateProfilePicture(File(_image!));
                        // for hiding bottom sheet
                        Navigator.pop(context);
                      }
                    },
                    child: Column(
                      children: [
                        const CircleAvatar(
                          child: Icon(Icons.camera_alt_rounded),
                        ),
                        const Text('Camera'),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (image != null) {
                        log('Image path: ${image.path} -- Mime type: ${image.mimeType}');
                        setState(() {
                          _image = image.path;
                        });

                        APIs.updateProfilePicture(File(_image!));

                        // for hiding bottom sheet
                        Navigator.pop(context);
                      }
                    },
                    child: Column(
                      children: [
                        const CircleAvatar(
                          child: Icon(Icons.photo),
                        ),
                        const Text('Gallery'),
                      ],
                    ),
                  )
                ],
              )
            ],
          );
        });
  }
}
