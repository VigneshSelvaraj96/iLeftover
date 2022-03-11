
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseAuth{
  Future signInWithEmailAndPassword(String email, String password);
  Future createUserWithEmailAndPassword(String email, String password, String displayName);
  Future currentUserInfo();
  Future<String> signInWithGoogle();
  void signOutWithGoogle();
  Future setName(String displayName);
  Future updatePhotoURL(String photoURL);
  Future<String> getPhotoURL();
  Future<void> signOut();
  Future <String> getuid();
}


class Auth implements BaseAuth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future signInWithEmailAndPassword(String email, String password) async{ 
    AuthResult user = await _firebaseAuth.signInWithEmailAndPassword(email:email, password:password);
    return user;
  }

  Future <String> getuid() async {
     FirebaseUser user = await _firebaseAuth.currentUser();
     return user.uid;
  }

  Future createUserWithEmailAndPassword(String email, String password, String displayName) async{
    AuthResult user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password:password);
    UserUpdateInfo info = new UserUpdateInfo();
    info.displayName = displayName;
    user.user.updateProfile(info);

    Firestore.instance.collection('users').document(user.user.uid).setData(
      {
        'Full Name': displayName,
        'UserID': user.user.uid,
        'Email': user.user.email,
        'Favorite Food': 'Milk Steak',
        'photoURL': user.user.photoUrl
      }
    );
    return user;
  }

  Future currentUserInfo() async{
    FirebaseUser user = await _firebaseAuth.currentUser(); 
    return user;
  }
  
  Future<String> getPhotoURL() async{
    FirebaseUser user = await _firebaseAuth.currentUser(); 
    return user.photoUrl;
  }

  Future setName(String displayName) async{
    print(displayName);
    FirebaseUser user = await _firebaseAuth.currentUser(); 
    UserUpdateInfo info = new UserUpdateInfo();
    info.displayName = displayName;
    await user.updateProfile(info);
    await user.reload();
    Firestore.instance.collection('users').document(user.uid).setData(
      {
        'Full Name': displayName,
        'UserID': user.uid,
        'Email': user.email,
        'Favorite Food': 'Milk Steak',
        'photoURL': user.photoUrl
      }
    );
  }

  Future updatePhotoURL(String photoURL) async{
    print(photoURL);
    FirebaseUser user = await _firebaseAuth.currentUser(); 
    UserUpdateInfo info = new UserUpdateInfo();
    info.photoUrl = photoURL;
    await user.updateProfile(info);
    await user.reload();
    Firestore.instance.collection('users').document(user.uid).setData(
      {
        'Full Name': user.displayName,
        'UserID': user.uid,
        'Email': user.email,
        'Favorite Food': 'Milk Steak',
        'photoURL': photoURL
      }
    );
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
    final AuthResult authResult = await _firebaseAuth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  }

  void signOutWithGoogle() async {
      await googleSignIn.signOut();
    print("User Sign Out");
  }

}

