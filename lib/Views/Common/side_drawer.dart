import 'package:flutter/material.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/store.dart';
import 'package:shopping_app/Util/measure.dart';
import 'package:shopping_app/Views/Common/edit_location.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:shopping_app/Views/Common/edit_username.dart';
import 'package:shopping_app/Database/auth_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SideDrawer extends StatelessWidget {
  final AuthService _auth = AuthService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    
    //CollectionReference myUser = FirebaseFirestore.instance.collection('users');
    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);
    Store preferredStore;

    final TextStyle userInfoStyle = TextStyle(
      color: Colors.black87,
      fontSize: 16.0,
      height: 1.5,
    );

    Text userInfoText(String text) {

      return Text(
        text, 
        style: userInfoStyle,
      );
    }

    Widget displayStoreInfo(Map<String, dynamic> data) {

      return FutureBuilder<DocumentSnapshot>(
        future: db.getStoreSnapshot(data['preferredLocation']),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

          String message;
          
          if (snapshot.hasError) {
            message = "Something went wrong";
          }
          else if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> mapOfStore = snapshot.data.data();

            if (mapOfStore == null) {
              message = 'No store selected';
            }
            else {
              preferredStore = Store.storeFromMap(mapOfStore);
              message = preferredStore.fullAddress;
            }
          }
          else {
            message = 'LOADING';
          }

          return userInfoText('Store: $message');
        },
      );
    }

    Widget userStream = StreamBuilder(
      stream: db.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        else if (snapshot.hasData) {
          Map<String, dynamic> data = snapshot.data.data();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userInfoText('Username: ${data['username']}\nRank: ${data['rank']}'),
              displayStoreInfo(data)
            ],
          );
        }
        return Text("loading");
      }
    );

    return new Drawer( 
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: Measure.screenHeightFraction(context, .3),
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.blue[200],
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 15,
                    top: 15,
                    child: Icon(
                      Icons.account_circle,
                      color: Colors.black,
                      size: 50,
                    ),
                  ),
                  Positioned(
                    top: 75.0,
                    left: 16.0,
                    bottom: 10.0,
                    child: userStream,
                  ),
                ],
              ),
            )
          ),
          ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.edit_location),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text('Edit Location'),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateLocation(preferredStore: preferredStore,)
                ),
              );
            },
          ),
          ListTile(
              title: Row(
                children: <Widget>[
                  Icon(Icons.edit),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text('Edit Username'),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateUser()),
                );
              }),
          ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.person),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text('Sign Out'),
                ),
              ],
            ),
            onTap: () async {
              await _auth.signout();
            },
          ),
        ],
      ),
    );
  }
}
