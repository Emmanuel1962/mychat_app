import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:mychat_app/helper/helper_functions.dart';
import 'package:mychat_app/pages/login_page.dart';
import 'package:mychat_app/pages/view_page.dart';
import 'package:mychat_app/service/authservice.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<FormState> authkey = GlobalKey<FormState>();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool showPassword = false;
  String username = "";
  String email = "";
  String password = "";
  bool isLoading = false;
  AuthService authService = AuthService();

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
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
                  'assets/images/istockphoto-664584812-1024x1024.jpg'),
              fit: BoxFit.cover),
        ),
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
                          "Welcome To Nuel's App",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Create Your Account To Chat And Explore!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          controller: usernameCtrl,
                          decoration: InputDecoration(
                            label: const Text('Username'),
                            labelStyle: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.lightGreen,
                                style: BorderStyle.solid,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade300,
                            prefixIcon: const Icon(Icons.contact_page_outlined),
                          ),
                          onChanged: (value) {
                            setState(() {
                              username = value;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 10,
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
                          validator: (value) {
                            var emailVaild = EmailValidator.validate(value!);
                            if (!emailVaild) {
                              return "Please Enter Your E-mail";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
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
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Fill In Password";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        MaterialButton(
                          onPressed: () {
                            register();
                          },
                          minWidth: 200,
                          color: Colors.green,
                          shape: const StadiumBorder(),
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an accout?"),
                            TextButton(
                                onPressed: () {
                                  var route = MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  );
                                  Navigator.push(context, route);
                                },
                                child: const Text("Login")),
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

  register() async {
    setState(() {
      isLoading = true;
    });
    // this provides the details you have sign up with
    await authService
        .registerUserwithEmailandPassword(username, email, password)
        .then((value) async {
      if (value == true) {
        // saving the shared prefrence state
        await HelperFuctions.userLoggedInStatus(true);
        await HelperFuctions.emailLoggedInStatus(email);
        await HelperFuctions.usernameLoggedInStatus(username);
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
