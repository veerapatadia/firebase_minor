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
          "Messages",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,

        elevation: 0,
        //actions: [
        // IconButton(
        //   onPressed: () async {
        //     await Auth_Helper.auth_helper.SignOutUser();
        //     Navigator.of(context)
        //         .pushNamedAndRemoveUntil('login_page', (routs) => false);
        //   },
        //   icon: Icon(
        //     Icons.power_settings_new,
        //     color: Colors.black,
        //   ),
        // ),
        // ],
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
                var userEmail = allDocs[i].data()['email'];
                var firstLetter = userEmail[0].toUpperCase();

                var photoUrl = allDocs[i].data()['photoUrl'];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xff0B2F9F),
                    child: (photoUrl != null && photoUrl.isNotEmpty)
                        ? ClipOval(
                            child: Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                          )
                        : Text(
                            firstLetter,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  title: (Auth_Helper.firebaseAuth.currentUser!.email ==
                          allDocs[i].data()['email'])
                      ? Text("${allDocs[i].data()['email']} (You)")
                      : Text("${allDocs[i].data()['email']}"),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('chat_page', arguments: allDocs[i].data());
                  },
                  subtitle: Text(
                    "",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Text(
                    "1212",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
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
