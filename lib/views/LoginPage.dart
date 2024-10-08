import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../helper/Auth_Helper.dart';
import '../helper/fcm_notification_helper.dart';
import '../helper/firestore_helper.dart';

class LoginPage1 extends StatefulWidget {
  const LoginPage1({super.key});

  @override
  State<LoginPage1> createState() => _LoginPage1State();
}

class _LoginPage1State extends State<LoginPage1> {
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? email;
  String? password;
  // String? token;

  Future<void> getFCMToken() async {
    await FCMNotificationHelper.fcmNotification.fetchFCmToken();
  }

  @override
  void initState() {
    super.initState();
    getFCMToken();
    requestPermission();
  }

  Future<void> requestPermission() async {
    PermissionStatus notificationPermissionStatus =
        await Permission.notification.request();
    log("=================");
    log("${notificationPermissionStatus}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Form(
            key: signInFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Sign in to continue",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // TextButton(
                //   onPressed: () async {
                //     await FCMNotificationHelper.fcmNotification.sendFCM(
                //         msg: "Hie",
                //         senderEmail: "You got notification",
                //         token: "");
                //   },
                //   child: Text("Show notification"),
                // ),
                SizedBox(height: 30),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please Enter Email First...";
                    }
                    return null;
                  },
                  onSaved: (val) {
                    email = val;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    hintText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please enter your password.";
                    } else if (val.length <= 6) {
                      return "Password must contain at least 6 characters.";
                    }
                    return null;
                  },
                  onSaved: (val) {
                    password = val;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    hintText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (signInFormKey.currentState!.validate()) {
                      signInFormKey.currentState!.save();

                      Map<String, dynamic> res = await Auth_Helper.auth_helper
                          .signInWithEmailAndPassword(
                              email: email!, password: password!);

                      if (res['user'] != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Signed in successfully."),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', (route) => false,
                            arguments: res['user']);
                      } else if (res['error'] != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${res['error']}"),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Sign in failed."),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.of(context).pop();
                      }

                      emailController.clear();
                      passwordController.clear();
                      email = null;
                      password = null;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0B2F9F),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    minimumSize: Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "LOGIN",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      // color: Color(0xFF556080),
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "or",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.g_mobiledata, size: 40),
                      color: Colors.red,
                      onPressed: () async {
                        Map<String, dynamic> res =
                            await Auth_Helper.auth_helper.signInWithGoogle();

                        if (res['user'] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("Signed in successfully with Google."),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          User user = res['user'];
                          await FireStoreHelper.fireStoreHelper
                              .addAuthenticatedUser(email: user.email!);

                          Navigator.of(context).pushReplacementNamed('/',
                              arguments: res['user']);
                        } else if (res['error'] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${res['error']}"),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Sign in with Google failed."),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.person_outline, size: 30),
                      onPressed: () async {
                        Map<String, dynamic> res =
                            await Auth_Helper.auth_helper.signInAsGuestUser();

                        if (res['user'] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("Signed in successfully as a guest."),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.of(context).pushReplacementNamed('/',
                              arguments: res['user']);
                        } else if (res['error'] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${res['error']}"),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Sign in failed."),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('login_page2');
                      },
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          // color: Color(0xFF556080),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
