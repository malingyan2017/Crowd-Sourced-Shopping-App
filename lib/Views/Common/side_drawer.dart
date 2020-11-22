import 'package:flutter/material.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/store.dart';
import 'package:shopping_app/Util/measure.dart';
import 'package:shopping_app/Views/Common/edit_location.dart';
import 'package:shopping_app/Views/Common/edit_username.dart';
import 'package:shopping_app/Database/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SideDrawer extends StatelessWidget {
  final AuthService _auth = AuthService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    const String noPreferredStore = 'A store has not been selected.';
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

    Widget userStream = StreamBuilder(
      stream: db.getCurrentUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        } 
        else if (snapshot.hasData) {
          Map<String, dynamic> data = snapshot.data.data();
          Store preferredStore;
          int userPoints = data['rankPoints'];
          String userRank = DatabaseService(uid: auth.currentUser.uid)
              .getUserRank(userPoints);
          Icon icon = db.getRankIcon(userPoints);

          if (data['preferredLocation'] != null) {
            preferredStore = Store.storeFromMap(data['preferredLocation']);
          }

          Widget padding = const Padding(padding: EdgeInsets.only(top: 2, bottom: 2),);

          return ListView(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.account_circle,
                  color: Colors.black,
                  size: 50,
                ),
              ),
              padding,
              Container(
                child: Row(
                  children: <Widget>[
                    userInfoText('${data['username']} '),
                    icon,
                  ],
                ),
              ),
              padding,
              Container(
                child: userInfoText('Rank : $userRank'),
              ),
              padding,
              Container(
                child: preferredStore == null
                  ? userInfoText('Store: $noPreferredStore')
                  : userInfoText('Store: ${preferredStore.fullAddress}')
              )
            ],
          );
        }
        else {
          return Text("loading");
        }
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
                  color: Theme.of(context).primaryColor,
                ),
                child: userStream,
              )),
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
                    builder: (context) => UpdateLocation(
                          preferredStore: preferredStore,
                        )),
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
