import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mychat_app/helper/helper_functions.dart';
import 'package:mychat_app/pages/login_page.dart';
import 'package:mychat_app/pages/profile_page.dart';
import 'package:mychat_app/pages/search_page.dart';
import 'package:mychat_app/service/authservice.dart';
import 'package:mychat_app/service/database_service.dart';
import 'package:mychat_app/widgets/group_tile.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({super.key});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  bool isloading = false;
  String groupName = "";

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  // string manipulation
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  gettingUserData() async {
    await HelperFuctions.getemailLoggedInStatus().then((value) => setState(() {
          email = value!;
        }));
    await HelperFuctions.getusernameLoggedInKey().then((value) => setState(() {
          userName = value!;
        }));

    // getting list of snapshot in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GROUPS',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
              onPressed: () {
                var route =
                    MaterialPageRoute(builder: (context) => const SearchPage());
                Navigator.push(context, route);
              },
              icon: const Icon(Icons.search_sharp))
        ],
        elevation: 0,
      ),
      drawer: Drawer(
        width: 150,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            const Icon(
              Icons.account_circle_sharp,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            ListTile(
              selected: true,
              selectedColor: Colors.green,
              onTap: () {},
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            ListTile(
              onTap: () {
                var route = MaterialPageRoute(
                    builder: (context) => ProfilePage(
                          userName: userName,
                          email: email,
                        ));
                Navigator.push(context, route);
              },
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
              leading: const Icon(Icons.person_3),
              title: const Text(
                'Profile',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            ListTile(
              onTap: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: ((context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel_outlined,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                await authService.signout();
                                var route = MaterialPageRoute(
                                    builder: (context) => const LoginPage());
                                Navigator.push(context, route);
                                // Navigator.of(context).pushAndRemoveUntil(
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             const LoginPage()),
                                //     (route) => false);
                              },
                              icon: const Icon(
                                Icons.done_rounded,
                                color: Colors.green,
                              )),
                        ],
                      );
                    }));
              },
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
              leading: const Icon(Icons.logout_outlined),
              title: const Text(
                "Logout",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            )
          ],
        ),
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            popupDialog(context);
          },
          elevation: 0,
          backgroundColor: Colors.green,
          child: const Icon(
            Icons.add,
            size: 30,
            color: Colors.white,
          )),
    );
  }

  groupList() {
    return StreamBuilder(
        stream: groups,
        builder: (context, AsyncSnapshot snapshot) {
          // make some checks
          if (snapshot.hasData) {
            if (snapshot.data['groups'] != null) {
              if (snapshot.data['groups'].length != 0) {
                return ListView.builder(
                    itemCount: snapshot.data['groups'].length,
                    itemBuilder: (context, index) {
                      int reverseIndex =
                          snapshot.data["groups"].length - index - 1;
                      return GroupTile(
                          userName: snapshot.data[
                              'Username'], // the Username is gotten from the way iwrote it in my firebase
                          groupId: getId(snapshot.data["groups"][reverseIndex]),
                          groupName:
                              getName(snapshot.data["groups"][reverseIndex]));
                    });
              } else {
                return noGroupWidget();
              }
            } else {
              return noGroupWidget();
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }
        });
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popupDialog(context);
            },
            child: const Icon(
              Icons.add_circle,
              color: Colors.black,
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You haven't joined any group, click the add button above to create a group.",
            textAlign: TextAlign.center,
          ),
          const Text(
            "OR",
            textAlign: TextAlign.center,
          ),
          const Text(
            "Click the search button to search for a group. ",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  popupDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text("Create group", textAlign: TextAlign.left),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isloading == true
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.green),
                        )
                      : TextField(
                          onChanged: (value) {
                            setState(() {
                              groupName = value;
                            });
                          },
                          style: const TextStyle(
                              color: Colors.black, fontSize: 10),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.deepPurple),
                                  borderRadius: BorderRadius.circular(20)),
                              errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(20)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                    const BorderSide(color: Colors.deepPurple),
                              )),
                        )
                ],
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () async {
                      if (groupName != "") {
                        setState(() {
                          isloading = false;
                        });
                        DatabaseService(
                                uid: FirebaseAuth.instance.currentUser!.uid)
                            .createGroup(
                                userName,
                                FirebaseAuth.instance.currentUser!.uid,
                                groupName)
                            .whenComplete(() {
                          isloading = false;
                        });
                        Navigator.of(context).pop();
                        showSnackbar(
                            context, "Group created Sucessfully", Colors.blue);
                      }
                    },
                    child: const Text("Create"))
              ],
            );
          });
        });
  }
}

void showSnackbar(context, message, color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {},
        textColor: Colors.white,
      ),
    ),
  );
}
