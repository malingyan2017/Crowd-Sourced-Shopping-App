import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/Views/Common/app_bar.dart';
import 'package:shopping_app/Views/Common/side_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateUser extends StatelessWidget {
  static const String routeName = '/updateUser';
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    CollectionReference myUser = FirebaseFirestore.instance.collection('users');
    //where('uid', isEqualTo: auth.currentUser.uid);
    return Scaffold(
      drawer: new SideDrawer(),
      appBar: MyAppBar('Edit Username'),
      body: FutureBuilder<DocumentSnapshot>(
        future: myUser.doc(auth.currentUser.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data = snapshot.data.data();
            return Text("Username: ${data['username']}");
          }

          return Text("loading");
        },
      ),
    );
  }
}
