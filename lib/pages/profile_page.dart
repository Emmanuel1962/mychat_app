import 'package:flutter/material.dart';
import 'package:mychat_app/pages/login_page.dart';
import 'package:mychat_app/pages/view_page.dart';
import 'package:mychat_app/service/authservice.dart';

class ProfilePage extends StatefulWidget {
  String userName;
  String email;
  ProfilePage({super.key, required this.userName, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          "Profile",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 25),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        width: 150,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: [
            const Icon(
              Icons.account_circle_sharp,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              widget.userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            ListTile(
              onTap: () {
                var route =
                    MaterialPageRoute(builder: (context) => const ViewPage());
                Navigator.push(context, route);
              },
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
              selected: true,
              selectedColor: Colors.green,
              onTap: () {},
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.account_circle_sharp,
              size: 120,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Username :",
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  widget.userName,
                  style: const TextStyle(fontSize: 17),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Email :",
                  style: const TextStyle(fontSize: 17),
                ),
                Text(
                  widget.email,
                  style: const TextStyle(fontSize: 17),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
