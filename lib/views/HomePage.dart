import 'package:chat_app/components/drawer.dart';
import 'package:chat_app/helper/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper/auth_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    // User user = ModalRoute.of(context)!.settings.arguments as User;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "HomePage",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black54,
        actions: [
          IconButton(
            onPressed: () async {
              await Auth_Helper.auth_helper.SignOutUser();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('login_page', (routs) => false);
            },
            icon: Icon(
              Icons.power_settings_new,
              color: Colors.white,
            ),
          ),
        ],
      ),
      drawer: (user == null)
          ? Drawer()
          : My_Drawer(
              user: user,
            ),
      body: StreamBuilder(
        stream: FireStoreHelper.fireStoreHelper.fetchAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("ERROR : ${snapshot.error}"));
          } else if (snapshot.hasData) {
            QuerySnapshot<Map<String, dynamic>>? data = snapshot.data;

            List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                (data == null) ? [] : data.docs;

            return ListView.separated(
              itemCount: allDocs.length,
              separatorBuilder: (context, i) {
                return SizedBox(
                  height: 10,
                );
              },
              itemBuilder: (context, i) {
                return ListTile(
                  leading: CircleAvatar(radius: 20),
                  title: (Auth_Helper.firebaseAuth.currentUser!.email ==
                          allDocs[i].data()['email'])
                      ? Text("You(${allDocs[i].data()['email']})")
                      : Text("${allDocs[i].data()['email']}"),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('chat_page', arguments: allDocs[i].data());
                  },
                  // trailing: IconButton(
                  //   icon: Icon(Icons.delete),
                  //   onPressed: () async {
                  //     await FireStoreHelper.fireStoreHelper
                  //         .deleteUser(docId: allDocs[i].id);
                  //   },
                  // ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
