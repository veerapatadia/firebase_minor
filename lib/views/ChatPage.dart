import 'package:chat_app/helper/Auth_Helper.dart';
import 'package:chat_app/helper/fcm_notification_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../helper/firestore_helper.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController chatController = TextEditingController();
  TextEditingController editController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> receiverEmail =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.black54,
        centerTitle: true,
        title: (receiverEmail['email'] ==
                Auth_Helper.firebaseAuth.currentUser!.email)
            ? Text(
                "Chat Page\nYou",
                style: TextStyle(color: Colors.white),
              )
            : Text(
                "Chat Page\n$receiverEmail",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 14,
            child: Container(
              padding: EdgeInsets.all(16),
              child: FutureBuilder(
                future: FireStoreHelper.fireStoreHelper
                    .fetchAllMessages(receiverEmail: receiverEmail['email']),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("ERROR : ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    Stream<QuerySnapshot<Map<String, dynamic>>>? dataStream =
                        snapshot.data;

                    return StreamBuilder(
                      stream: dataStream,
                      builder: (context, ss) {
                        if (ss.hasError) {
                          return Center(child: Text("ERROR : ${ss.error}"));
                        } else if (ss.hasData) {
                          QuerySnapshot<Map<String, dynamic>>? data = ss.data;

                          List<QueryDocumentSnapshot<Map<String, dynamic>>>
                              allMessages = (data == null) ? [] : data.docs;

                          return (allMessages.isEmpty)
                              ? Center(
                                  child: Text("No any messages yet..."),
                                )
                              : ListView.builder(
                                  reverse: true,
                                  itemCount: allMessages.length,
                                  itemBuilder: (context, i) {
                                    return Row(
                                      mainAxisAlignment:
                                          (receiverEmail['email'] !=
                                                  allMessages[i]
                                                      .data()['receiverEmail'])
                                              ? MainAxisAlignment.start
                                              : MainAxisAlignment.end,
                                      children: [
                                        PopupMenuButton<String>(
                                          onSelected: (val) async {
                                            if (val == 'delete') {
                                              return showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      "Are you sure",
                                                    ),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            "Cancel"),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          FireStoreHelper
                                                              .fireStoreHelper
                                                              .deleteMessage(
                                                                  receiverEmail:
                                                                      receiverEmail[
                                                                          'email'],
                                                                  messageDocId:
                                                                      allMessages[
                                                                              i]
                                                                          .id);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            "Delete"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                            if (val == 'edit') {
                                              return showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      "Edit Message",
                                                    ),
                                                    content: TextFormField(
                                                      decoration:
                                                          const InputDecoration(
                                                              hintText:
                                                                  "Edit Message..."),
                                                      textInputAction:
                                                          TextInputAction.next,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      controller:
                                                          editController,
                                                    ),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          editController
                                                              .clear();
                                                        },
                                                        child: const Text(
                                                          "Cancel",
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          FireStoreHelper
                                                              .fireStoreHelper
                                                              .updateMessage(
                                                            msg: editController
                                                                .text,
                                                            receiverEmail:
                                                                receiverEmail[
                                                                    'email'],
                                                            messageDocId:
                                                                allMessages[i]
                                                                    .id,
                                                          );
                                                          Navigator.of(context)
                                                              .pop();
                                                          editController
                                                              .clear();
                                                        },
                                                        child: const Text(
                                                          "Edit",
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                          ],
                                          position: PopupMenuPosition.under,
                                          child: Chip(
                                            label: Text(
                                              "${allMessages[i].data()['msg']}",
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(12),
              child: TextField(
                controller: chatController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter message here...",
                  suffixIcon: IconButton(
                    onPressed: () async {
                      String msg = chatController.text;
                      await FireStoreHelper.fireStoreHelper.sendMessage(
                        msg: msg,
                        receiverEmail: receiverEmail['email'],
                      );
                      chatController.clear();
                      await FirebaseMessaging.instance.getToken();
                      await FCMNotificationHelper.fcmNotification.sendFCM(
                        msg: msg,
                        senderEmail:
                            Auth_Helper.firebaseAuth.currentUser!.email!,
                        token: receiverEmail['token'],
                      );
                    },
                    icon: Icon(Icons.send),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
