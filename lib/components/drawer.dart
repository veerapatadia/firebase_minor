import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../helper/Auth_Helper.dart';

class My_Drawer extends StatefulWidget {
  final User user;
  My_Drawer({required this.user});

  @override
  State<My_Drawer> createState() => _My_DrawerState();
}

class _My_DrawerState extends State<My_Drawer> {
  final GlobalKey<FormState> usernameKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? userName;
  String? password;

  @override
  void initState() {
    super.initState();
    userName = widget.user.displayName;
  }

  bool isGoogle() {
    for (var data in widget.user.providerData) {
      if (data.providerId == "google.com") {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: widget.user.isAnonymous ||
                            widget.user.photoURL == null
                        ? NetworkImage(
                            "https://i.pinimg.com/564x/3d/91/09/3d910919cf4d41c1114457504dc29201.jpg")
                        : NetworkImage(widget.user.photoURL!) as ImageProvider,
                  ),
                  SizedBox(height: 10),
                  Text(
                    (widget.user.isAnonymous)
                        ? "Guest User"
                        : userName ?? 'Unknown User',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!widget.user.isAnonymous)
                    Text(
                      "${widget.user.email}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person_outline, color: Colors.grey[800]),
            title: Text(
              "Edit Username",
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              showEditUsernameDialog();
            },
          ),
          (widget.user.isAnonymous || isGoogle())
              ? Container()
              : ListTile(
                  leading: Icon(Icons.lock_outline, color: Colors.grey[800]),
                  title: Text(
                    "Change Password",
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    showChangePasswordDialog();
                  },
                ),
          Spacer(),
        ],
      ),
    );
  }

  void showEditUsernameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Username"),
          content: Form(
            key: usernameKey,
            child: TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (val) => val!.isEmpty ? "Enter a username" : null,
              onSaved: (val) => userName = val,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                usernameController.clear();
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: () async {
                if (usernameKey.currentState!.validate()) {
                  usernameKey.currentState!.save();
                  User? updatedUser =
                      await Auth_Helper.auth_helper.updateUsername(userName!);
                  if (updatedUser != null) {
                    setState(() {
                      userName = updatedUser.displayName;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Username updated successfully!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to update username."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  usernameController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                "Save",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change Password"),
          content: Form(
            key: passwordKey,
            child: TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (val) => val!.isEmpty ? "Enter a password" : null,
              onSaved: (val) => password = val,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                passwordController.clear();
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: () async {
                if (passwordKey.currentState!.validate()) {
                  passwordKey.currentState!.save();
                  bool isUpdated =
                      await Auth_Helper.auth_helper.updatePassword(password!);
                  if (isUpdated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Password updated successfully!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to update password."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  passwordController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                "Save",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
