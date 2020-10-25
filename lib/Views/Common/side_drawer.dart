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

          // https://stackoverflow.com/questions/56326005/how-to-use-expanded-in-singlechildscrollview
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  child: Icon(
                    Icons.account_circle,
                    color: Colors.black,
                    size: 50,
                  ),
                ),
              ),
              Flexible(
                child: Container(child: userInfoText('Username: ${data['username']}'))
              ),
              Flexible(
                child: Container(child: userInfoText('Rank: ${data['rank']}'))
              ),
              Flexible(
                flex: 2,
                child: Container(child: displayStoreInfo(data))
              )
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
            height: _userPaneSize(context),
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[200],
              ),
              child: userStream,
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

// https://stackoverflow.com/questions/51284589/flutter-how-to-know-the-device-is-deviceorientation-is-up-or-down
double _userPaneSize(BuildContext context) {

  Orientation orientation = MediaQuery.of(context).orientation;

  return orientation == Orientation.portrait
  ? Measure.screenHeightFraction(context, .4)
  : Measure.screenHeightFraction(context, .6);
}
