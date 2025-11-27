import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mychat_app/pages/group_info.dart';
import 'package:mychat_app/pages/message_tile.dart';
import 'package:mychat_app/service/database_service.dart';

class ChatPage extends StatefulWidget {
  final String groupName;
  final String userName;
  final String groupId;

  const ChatPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messagesCtrl = TextEditingController();
  Stream<QuerySnapshot>? chats;
  String admin = "";

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((value) {
      setState(() {
        chats = value;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((value) {
      setState(() {
        admin = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
              onPressed: () {
                var route = MaterialPageRoute(
                    builder: (context) => GroupInfo(
                          groupId: widget.groupId,
                          groupName: widget.groupName,
                          adminName: admin,
                        ));
                Navigator.push(context, route);
              },
              icon: const Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: [
          //chats messages
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width:
                MediaQuery.of(context).size.width, // this take the whole space
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messagesCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: "Send a message...",
                          hintStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30)),
                      child: const Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                        message: snapshot.data.docs[index]["message"],
                        sender: snapshot.data.docs[index]["sender"],
                        sentByMe: widget.userName ==
                            snapshot.data.docs[index]["sender"]);
                  })
              : Container();
        });
  }

  sendMessage() {
    if (messagesCtrl.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messagesCtrl.text,
        "sender": widget.userName,
        "time": DateTime.now().microsecondsSinceEpoch,
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messagesCtrl.clear();
      });
    }
  }
}
