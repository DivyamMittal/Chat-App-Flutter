import 'dart:developer';

import 'package:chat_app/Apis/apis.dart';
import 'package:chat_app/Models/chat_user.dart';
import 'package:chat_app/Screens/profile_screen.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Widgets/chat_user_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();

    // updating online and offline status of user in firebase
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      // setting the status online and offline statud with last seen
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        setState(() {});
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: _isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: "Search..."),
                      autofocus: true,
                      onChanged: (val) {
                        _searchList.clear();
                        for (var i in _list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                    )
                  : const Text('Chat'),
              leading: _isSearching
                  ? IconButton(
                      icon: const Icon(CupertinoIcons.back),
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                        });
                      },
                    )
                  : null,
              actions: [
                _isSearching
                    ? Container()
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                          });
                        },
                        icon: const Icon(Icons.search_rounded)),
                _isSearching
                    ? Container()
                    : IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreen(user: APIs.me)));
                        },
                        icon: const Icon(Icons.more_vert))
              ],
            ),

            // floating action button
            floatingActionButton: !_isSearching
                ? FloatingActionButton(
                    onPressed: () async {
                      _showAddUserDialog();
                    },
                    child: const Icon(Icons.person_add_alt_1_rounded),
                  )
                : Container(),

            // body
            body: StreamBuilder(
              stream: APIs.getMyUsersId(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());

                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                      stream: APIs.getAllUsers(
                          snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(
                                child: CircularProgressIndicator());

                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => ChatUser.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  itemCount: _isSearching
                                      ? _searchList.length
                                      : _list.length,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.only(top: 10),
                                  itemBuilder: ((context, index) {
                                    return ChatUserCard(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index],
                                    );
                                  }));
                            } else {
                              return const Center(
                                child: Text(
                                  "No chats found!",
                                  style: TextStyle(fontSize: 18),
                                ),
                              );
                            }
                        }
                      },
                    );
                }
              },
            )),
      ),
    );
  }

  // dialog for add user
  void _showAddUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(children: [Text('  Enter email')]),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_rounded),
                    border: OutlineInputBorder(
                        borderSide:
                            const BorderSide(width: 2, color: Colors.blue),
                        borderRadius: BorderRadius.circular(15))),
              ),

              // action buttons
              actions: [
                // cancel button
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),

                // update button
                MaterialButton(
                  onPressed: () async {
                    // hide alert dialog box
                    Navigator.pop(context);

                    if (email.isNotEmpty) {
                      await APIs.addChatUser(email).then((value) {
                        if (!value) {
                          Dialogs.showSnackBar(
                              context, "User does not exists!");
                        }
                        if (value) {
                          Dialogs.showSnackBar(context, "User Added");
                        }
                      });
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                )
              ],
            ));
  }
}
