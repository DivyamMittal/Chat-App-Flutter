import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/Apis/apis.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SampleScreen extends StatefulWidget {
  const SampleScreen({super.key});

  @override
  State<SampleScreen> createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: APIs.firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              log(jsonEncode(snapshot.data!.docs[1].data()).toString());
              log(snapshot.data!.docs[index]['name'].toString());
              return Text(snapshot.data!.docs[index]['name'].toString());
            },
          );
        },
      ),
    );
  }
}
