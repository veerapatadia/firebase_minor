import 'package:chat_app/helper/Auth_Helper.dart';
import 'package:chat_app/helper/fcm_notification_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreHelper {
  FireStoreHelper._();
  static final FireStoreHelper fireStoreHelper = FireStoreHelper._();
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // add authenticated user
  Future<void> addAuthenticatedUser({required String email}) async {
    bool isUserExists = false;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("users").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
        querySnapshot.docs;

    allDocs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      Map<String, dynamic> docData = doc.data();

      if (docData['email'] == email) {
        isUserExists = true;
      }
    });

    // //auto generated
    // if (isUserExists == false) {
    //   await db.collection("users").add({
    //     "email": email,
    //
    //   });
    // }

    //auto increment
    if (isUserExists == false) {
      DocumentSnapshot<Map<String, dynamic>> qs =
          await db.collection("records").doc("users").get();

      Map<String, dynamic>? data = qs.data();

      int id = data!['id'];
      int counter = data!['counter'];

      id++;

      String? token =
          await FCMNotificationHelper.fcmNotification.fetchFCmToken();

      // manually id
      await db.collection("users").doc("$id").set({
        "email": email,
        "token": token,
      });
      counter++;

      await db.collection("records").doc("users").update({
        "id": id,
        "counter": counter,
      });
    }
  }

  // fetch all data
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllUsers() {
    return db.collection("users").snapshots();
  }

  //delete user
  Future<void> deleteUser({required String docId}) async {
    await db.collection("users").doc(docId).delete();

    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await db.collection("records").doc("users").get();

    int counter = userDoc.data()!['counter'];

    counter--;

    await db.collection("records").doc("users").update({
      "counter": counter,
    });
  }

  //create a chatroom & store messages
  Future<void> sendMessage(
      {required String msg, required String receiverEmail}) async {
    String senderEmail = Auth_Helper.firebaseAuth.currentUser!.email!;
    bool isChatroomExists = false;

    //check if a chatroom is already exists or not
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    String? chatroomId;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List users = chatroom.data()['users'];

      if (users.contains(receiverEmail) && users.contains(senderEmail)) {
        isChatroomExists = true;
        chatroomId = chatroom.id;
      }
    });

    if (isChatroomExists == false) {
      DocumentReference<Map<String, dynamic>> docRef =
          await db.collection("chatrooms").add({
        "users": [senderEmail, receiverEmail]
      });
      chatroomId = docRef.id;
    }

    //store a message
    await db
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .add({
      "msg": msg,
      "senderEmail": senderEmail,
      "receiverEmail": receiverEmail,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  //fetch all messages
  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> fetchAllMessages(
      {required String receiverEmail}) async {
    String senderEmail = Auth_Helper.firebaseAuth.currentUser!.email!;

    //check if a chatroom is already exists or not
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    String? chatroomId;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List users = chatroom.data()['users'];

      if (users.contains(receiverEmail) && users.contains(senderEmail)) {
        chatroomId = chatroom.id;
      }
    });

    return db
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // update message
  Future<void> updateMessage(
      {required String msg,
      required String receiverEmail,
      required String messageDocId}) async {
    String? senderEmail = Auth_Helper.firebaseAuth.currentUser!.email;

    //find a chatroom id
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    String? chatroomId;

    allChatrooms.forEach(
      (QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
        List users = chatroom.data()['users'];

        if (users.contains(receiverEmail) && users.contains(senderEmail)) {
          chatroomId = chatroom.id;
        }
      },
    );
    await db
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .doc(messageDocId)
        .update({
      "msg": msg,
      "updatedTimeStamp": FieldValue.serverTimestamp(),
    });
  }

  // delete message
  Future<void> deleteMessage(
      {required String receiverEmail, required String messageDocId}) async {
    String? senderEmail = Auth_Helper.firebaseAuth.currentUser!.email;

    //find a chatroom id

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatrooms =
        querySnapshot.docs;

    String? chatroomId;

    allChatrooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List users = chatroom.data()['users'];

      if (users.contains(receiverEmail) && users.contains(senderEmail)) {
        chatroomId = chatroom.id;
      }
    });
    await db
        .collection("chatrooms")
        .doc(chatroomId)
        .collection("messages")
        .doc(messageDocId)
        .delete();
  }
}
