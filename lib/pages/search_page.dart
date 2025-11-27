// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:mychat_app/helper/helper_functions.dart';
import 'package:mychat_app/pages/chat_page.dart';
import 'package:mychat_app/pages/view_page.dart';
import 'package:mychat_app/service/database_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchCtrl = TextEditingController();
  bool isJoined = false;
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearch = false;
  String userName = "";
  User? user;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    await HelperFuctions.getusernameLoggedInKey().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

// string manipulation
  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Search",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search groups",
                      hintStyle: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 10),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(40)),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : groupList(),
        ],
      ),
    );
  }

  initiateSearchMethod() async {
    if (searchCtrl.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DatabaseService().searchByName(searchCtrl.text).then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          isLoading = false;

          hasUserSearch = true;
        });
      });
    }
  }

  groupList() {
    return hasUserSearch
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                  userName,
                  searchSnapshot!.docs[index]["groupId"],
                  searchSnapshot!.docs[index]["groupName"],
                  searchSnapshot!.docs[index]["admin"]);
            })
        : Container();
  }

  joinedorNot(
      String userName, String groupId, String groupname, String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupname, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  groupTile(String userName, String groupId, String groupName, String admin) {
    // function to check whether the user already exist in the group
    joinedorNot(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        groupName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text("Admin : ${getName(admin)}"),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid)
              .toggleGroupJoin(groupId, userName, groupName);
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });
            showSnackbar(context, "Sucessfully joined the group", Colors.green);
            Future.delayed(const Duration(seconds: 5), () {
              var route = MaterialPageRoute(
                builder: (context) => ChatPage(
                    groupId: groupId, groupName: groupName, userName: userName),
              );
              Navigator.push(context, route);
            });
          } else {
            setState(() {
              isJoined = !isJoined;
            });
            showSnackbar(context, "Left the group $groupName", Colors.red);
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).primaryColor,
                    border: Border.all(color: Colors.white, width: 1)),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: const Text(
                  "Joined",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsetsDirectional.symmetric(
                    vertical: 12, horizontal: 12),
                child: const Text(
                  "Join Now...",
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }

  // joinedOrNot(
  //     String userName, String groupId, String groupname, String admin) async {
  //   await DatabaseService(uid: user!.uid)
  //       .isUserJoined(groupname, groupId, userName)
  //       .then((value) {
  //     setState(() {
  //       isJoined = true;
  //     });
  //   });
  // }

  //  Widget groupTile(
  //     String userName, String groupId, String groupName, String admin) {
  //   // function to check whether the user  already exist in the group
  //   joinedOrNot(userName, groupName, groupId, admin);
  //   return ListTile(
  //     contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //     leading: CircleAvatar(
  //       radius: 30,
  //       backgroundColor: Theme.of(context).primaryColor,
  //       child: Text(
  //         groupName.substring(0, 1).toUpperCase(),
  //         style: const TextStyle(color: Colors.black),
  //       ),
  //     ),
  //     title: Text(
  //       groupName,
  //       style: const TextStyle(fontWeight: FontWeight.bold),
  //     ),
  //     subtitle: Text(" Admin : ${getName(admin)}"),
  //     trailing: InkWell(
  //       onTap: () async {
  //         await DatabaseService(uid: user!.uid)
  // .toggleGroupJoin(groupId, userName, groupName);
  //         if (isJoined) {
  //           setState(() {
  //             isJoined = !isJoined;
  //           });
  //           showSnackbar(context, "Sucessfully joined the Group", Colors.blue);
  //           Future.delayed(const Duration(seconds: 5), () {
  //             var route = MaterialPageRoute(
  //                 builder: (context) => ChatPage(
  //                     groupId: groupId,
  //                     groupName: groupName,
  //                     userName: userName));
  //             Navigator.push(context, route);
  //           });
  //         } else {
  //           setState(() {
  //             isJoined = !isJoined;
  //           });
  //           showSnackbar(context, "Left the group $groupName", Colors.red);
  //         }
  //       },
  //       child: isJoined
  //           ? Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(10),
  //                 color: Colors.black,
  //                 border: Border.all(color: Colors.white, width: 1),
  //               ),
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  //               child: const Text(
  //                 "Joined",
  //                 style: TextStyle(
  //                   color: Colors.blueGrey,
  //                 ),
  //               ),
  //             )
  //           : Container(
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(10),
  //                 color: Colors.black,
  //                 border: Border.all(color: Colors.green, width: 1),
  //               ),
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  //               child: const Text(
  //                 "Join",
  //                 style: TextStyle(
  //                   color: Colors.indigo,
  //                 ),
  //               ),
  //             ),
  //     ),
  //   );
}
