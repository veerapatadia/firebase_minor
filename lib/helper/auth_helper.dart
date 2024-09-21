import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth_Helper {
  Auth_Helper._();
  static final Auth_Helper auth_helper = Auth_Helper._();
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static GoogleSignIn googleSignIn = GoogleSignIn();

  // sign in anonymously
  Future<Map<String, dynamic>> signInAsGuestUser() async {
    Map<String, dynamic> res = {};
    try {
      UserCredential userCredential = await firebaseAuth.signInAnonymously();

      User? user = userCredential.user;

      res['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "network-request-failed":
          res['error'] = "No Internet Available";
          break;
        case "operation-not-allowed":
          res['error'] = "This is disabled by admin";
          break;
        default:
          res['error'] = "${e.code}";
      }
    }
    return res;
  }

  //sign up with email and password
  Future<Map<String, dynamic>> signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    Map<String, dynamic> res = {};
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      res['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "network-request-failed":
          res['error'] = "No Internet Available";
          break;
        case "operation-not-allowed":
          res['error'] = "This is disabled by admin";
          break;
        case "weak-password":
          res['error'] = "Password must be greater than 6 letters";
          break;
        case "email-already-in-use":
          res['error'] = "This email is already exist";
        default:
          res['error'] = "${e.code}";
      }
    }
    return res;
  }

  //sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    Map<String, dynamic> res = {};
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      res['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "network-request-failed":
          res['error'] = "No Internet Available";
          break;
        case "operation-not-allowed":
          res['error'] = "This is disabled by admin";
          break;
        case "invalid-credential":
          res['error'] = "Invalid credential";
          break;
        default:
          res['error'] = "${e.code}";
      }
    }
    return res;
  }

  // //sign in with mobile
  // Future<User?> signInWithMobile({required String phoneNumber}) async {
  //   ConfirmationResult confirmationResult =
  //       await firebaseAuth.signInWithPhoneNumber(phoneNumber);
  //
  //   String smsCode = 'the code received via SMS';
  //
  //   UserCredential userCredential = await confirmationResult.confirm(smsCode);
  //   User? user = userCredential.user;
  //
  //   return user;
  // }

  // sign in with google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    Map<String, dynamic> res = {};
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);

      User? user = userCredential.user;
      res['user'] = user;
    } catch (e) {
      res['error'] = "${e}";
    }
    return res;
  }

//SignOut
  Future<void> SignOutUser() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }

//updateUserName
  Future<User?> updateUsername(String newUsername) async {
    User? user = firebaseAuth.currentUser;

    if (user != null) {
      await user.updateProfile(displayName: newUsername);
      await user.reload();
      user = firebaseAuth.currentUser;
      return user;
    }
    return null;
  }

  //updatePassword
  Future<bool> updatePassword(String newPassword) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        await user.reload();
        return true;
      } on FirebaseAuthException catch (e) {
        print("Failed to update password: ${e.message}");
        return false;
      }
    } else {
      print("No user is signed in");
      return false;
    }
  }
}
