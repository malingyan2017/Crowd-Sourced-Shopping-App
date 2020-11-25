import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'dart:math';

//borrow the concept of structure and part of code from the below tutorial of firebase
//https://github.com/iamshaunjp/flutter-firebase/blob/lesson-9/brew_crew/lib/screens/home/home.dart

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email;
  String password;

  //create our customed user class based on User in firebase
  TheUser _userFromUser(User user) {
    if (user != null) {
      return TheUser(uid: user.uid);
    } else {
      return null;
    }
  }

  //get auth changes from stream
  Stream<TheUser> get user {
    return _auth.authStateChanges().map((User user) => _userFromUser(user));
  }

  //sign in email & password
  Future signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFromUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //register email & password

  Future registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      final _random = new Random();
      int min = 1;
      int max = 1000000;
      int r = min + _random.nextInt(max - min);
      String number = r.toString();
      String member = 'member' + number;
      //create user data in data base with its uid when he register
      await DatabaseService(uid: user.uid).updateUsers(member, 0);
      return _userFromUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign out

  Future signout() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
