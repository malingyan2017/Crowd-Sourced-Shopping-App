import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  //create if not there or update the user data in data base
  Future updateUsers(String username, int rank) async {
    return await userCollection.doc(uid).set({
      'username': username,
      'rank': rank,
    });
  }
}
