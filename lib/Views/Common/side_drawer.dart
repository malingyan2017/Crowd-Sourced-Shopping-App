import 'package:flutter/material.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'package:shopping_app/Util/measure.dart';
import 'package:shopping_app/Views/Common/edit_location.dart';
import 'package:shopping_app/Views/Common/edit_username.dart';
import 'package:shopping_app/Database/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SideDrawer extends StatelessWidget {
  final AuthService _auth = AuthService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  static const String noPreferredStore = 'A store has not been selected.';

  @override
  Widget build(BuildContext context) {
    
    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);

    return StreamBuilder(
      stream: db.getCurrentUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        } 
        else if (snapshot.hasData) {

          TheUser user = db.createUserFromSnapshot(snapshot);

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
                    child: header(context, user, db),
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
                        builder: (context) => UpdateLocation(
                          preferredStore: user.preferredStore,
                        )
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
        else {
          return Text("loading");
        }
      }
    );
  }

  Widget header(BuildContext context, TheUser user, DatabaseService db) {

    int userPoints = user.rankPoints;
    String userRank = db.getUserRank(userPoints);
    Icon icon = db.getRankIcon(userPoints);

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
              userInfoText('${user.username} '),
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
          child: user.preferredStore == null
            ? userInfoText('Store: $noPreferredStore')
            : userInfoText('Store: ${user.preferredStore.fullAddress}')
        )
      ],
    );
  }

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
}

// https://stackoverflow.com/questions/51284589/flutter-how-to-know-the-device-is-deviceorientation-is-up-or-down
double _userPaneSize(BuildContext context) {
  Orientation orientation = MediaQuery.of(context).orientation;

  return orientation == Orientation.portrait
      ? Measure.screenHeightFraction(context, .4)
      : Measure.screenHeightFraction(context, .6);
}
