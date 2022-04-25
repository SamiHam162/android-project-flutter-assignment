import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }


class AuthRepository with ChangeNotifier {

  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  FirebaseAuth _auth;
  User? _user;
  Status _status = Status.Uninitialized;

  AuthRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _user = _auth.currentUser;
    _onAuthStateChanged(_user);
  }

  Status get status => _status;

  User? get user => _user;

  bool get isAuthenticated => status == Status.Authenticated;

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      UserCredential? credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // await FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser?.uid).set({'Photo': 'https://firebasestorage.googleapis.com/v0/b/hellome-69159.appspot.com/o/ProfilePicture.png?alt=media&token=f3805d7e-3773-4627-a414-af4cfda1e08e'});
      return credential;
    } catch (e) {
      print(e);
      _status = Status.Unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
      //theUser? the = _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided.');
      }
    }

    return user;
  }


  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }
  Future<String?> currentUser() async {
    User user = FirebaseAuth.instance.currentUser!;
    return user != null ? user.uid : null;
  }

  Future<String> downloadImage() async {
    String? uid = _user?.uid;
    try {
      print(_user!.uid);
      return await FirebaseStorage.instance.ref('images/'  ).child(uid!).getDownloadURL();
    } on Exception catch (e) {
      print("noHi");
      return "https://firebasestorage.googleapis.com/v0/b/hellome-69159.appspot.com/o/ProfilePicture.png?alt=media&token=f3805d7e-3773-4627-a414-af4cfda1e08e";
    }
  }
  Future<void> uploadImage(File file) async{
    print("uploaded");
    await FirebaseStorage.instance.ref('images/' + _user!.uid).putFile(file);
    notifyListeners();
  }



}