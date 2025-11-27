import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mychat_app/pages/home_page.dart';
import 'package:mychat_app/pages/view_page.dart';
import 'package:mychat_app/service/authservice.dart';
import 'package:mychat_app/service/database_service.dart';

import '../helper/helper_functions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> authkey = GlobalKey<FormState>();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool showPassword = false;
  String email = "";
  String password = "";
  bool isLoading = false;
  AuthService authService = AuthService();
  @override
  void dispose() {
    super.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
  }

  switchPassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                  'assets/images/istockphoto-1184334819-1024x1024.jpg'),
              fit: BoxFit.cover),
        ),

        // BackdropFliter is used for fading a picture at the background
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                    key: authkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Login To See What They Are Talking!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          controller: emailCtrl,
                          decoration: InputDecoration(
                            label: const Text("Email"),
                            labelStyle: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              // fontSize: 10,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: Colors.lightGreen,
                                    style: BorderStyle.solid)),
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.grey.shade300,
                          ),
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          },
                          validator: (value) {
                            var emailVaild = EmailValidator.validate(value!);
                            if (!emailVaild) {
                              return "Please Enter Your E-mail";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          obscureText: showPassword,
                          controller: passwordCtrl,
                          decoration: InputDecoration(
                            label: const Text("Password"),
                            labelStyle: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              // fontSize: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                style: BorderStyle.solid,
                                color: Colors.lightGreenAccent,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade300,
                            prefixIcon: const Icon(Icons.lock_rounded),
                            suffixIcon: IconButton(
                              onPressed: () {
                                switchPassword();
                              },
                              icon: showPassword
                                  ? const Icon(Icons.remove_red_eye)
                                  : const Icon(Icons.visibility_off),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Fill In Password";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        MaterialButton(
                          onPressed: () {
                            login();
                          },
                          minWidth: 200,
                          color: Colors.green,
                          shape: const StadiumBorder(),
                          child: const Text(
                            "Sign in",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an accout?"),
                            TextButton(
                                onPressed: () {
                                  var route = MaterialPageRoute(
                                    builder: (context) => const HomePage(),
                                  );
                                  Navigator.push(context, route);
                                },
                                child: const Text("Sign Up")),
                          ],
                        )
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  login() async {
    setState(() {
      isLoading = true;
    });
    // this provides the details you have sign up with
    await authService
        .loginUserWithEmailandPassword(email, password)
        .then((value) async {
      // checkimg if the value is true
      if (value == true) {
        QuerySnapshot snapshot =
            await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                .gettingUserData(email);
//saving our values to our shared prefrences
        await HelperFuctions.userLoggedInStatus(true);
        await HelperFuctions.emailLoggedInStatus(email);
        await HelperFuctions.usernameLoggedInStatus(
            snapshot.docs[0]["Username"]);
        var route = MaterialPageRoute(
          builder: (context) => const ViewPage(),
        );

        Navigator.push(context, route);
      } else {
        showSnackbar(
            context,
            value,
            Colors
                .red); // make sure you put the conditions here the same way you did when creating it as a function below
        setState(() {
          isLoading = false;
        });
      }
    });
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
}
