import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:cached_network_image/cached_network_image.dart';

// https://stackoverflow.com/questions/54751007/cloud-functions-for-firestore-accessing-parent-collection-data
// https://github.com/flutter/flutter/issues/15928
// https://pub.dev/packages/cached_network_image

class LivePriceUpdates extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);
    // Text Widget to Bold Item Text
    Text itemInfoText(String text) {
      return Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // Text Widget for Price Styling
    Text itemPriceText(String text) {
      return Text(
        text,
        style: TextStyle(
          color: Colors.green[800],
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      );
    }

    // Variable to hold the query for latest store item updates
    var storeItems = FirebaseFirestore.instance
        .collectionGroup('storeItems')
        .orderBy('dateUpdated', descending: true)
        .limit(10);

    // Widget to retrieve location info such as store name, city state, and zip code
    Widget getLocation(String locationID) {
      var userData =
          FirebaseFirestore.instance.collection('stores').doc(locationID).get();

      return FutureBuilder<DocumentSnapshot>(
          future: userData,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            String message;
            if (snapshot.hasError) {
              message = "Something went wrong";
            }

            if (snapshot.hasData &&
                snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> locationData = snapshot.data.data();
              message = locationData['name'] +
                  ' in ' +
                  locationData['city'] +
                  ', ' +
                  locationData['state'] +
                  ' ' +
                  locationData['zipCode'];
            } else {
              message = "LOADING";
            }

            return Text(message);
          });
    }

    // Widget to retrieve user information such as rank and username
    Widget getUserInfo(String userId) {
      var userData =
          FirebaseFirestore.instance.collection('users').doc(userId).get();

      return FutureBuilder<DocumentSnapshot>(
          future: userData,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            String message;
            if (snapshot.hasError) {
              message = "Something went wrong";
            }
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> userData = snapshot.data.data();

              // Calculate User's rank and retrieve icon
              int userPoints = userData['rankPoints'];
              Icon icon = db.getRankIcon(userPoints);
              String user = 'Updated by: ' + userData['username'] + ' ';

              return Row(
                children: <Widget>[
                  Text(user), icon, //Text(rank)
                ],
              );
            } else {
              message = "LOADING";
            }
            return Text(message);
          });
    }

    return Scaffold(
      // Stream builder to listen to the latest price updates for the live feed
      body: StreamBuilder(
        stream: storeItems.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          } else if (snapshot.hasData) {
            return new ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot data = snapshot.data.docs[index];

                // Get parent ID of store location
                var storeId = data.reference.parent.parent.id;

                // Get formatted time stamp of when price update was posted
                Timestamp timestamp = data['dateUpdated'];
                DateTime myDateTime =
                    DateTime.parse(timestamp.toDate().toString());
                String formattedDateTime =
                    DateFormat('MM-dd-yyyy').format(myDateTime);

                // Variables to Hold Store Item Info
                var itemName = data['name'];
                var itemPrice = '\$' + data['price'].toStringAsFixed(2);
                var onSale = data['onSale'];
                var userId = data['userId'];

                return SizedBox(
                  height: 90,
                  child: Card(
                    child: Stack(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 60,
                              height: 60,
                              child: CachedNetworkImage(
                                imageUrl: data['pictureUrl'],
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0, bottom: 25.0),
                              child: itemInfoText(itemName),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 10,
                          right: 3,
                          child: Stack(
                            children: <Widget>[
                              Text('$formattedDateTime'),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 30,
                          left: 70,
                          child: itemPriceText(itemPrice),
                        ),
                        Positioned(
                          left: 45,
                          top: 46,
                          child: Checkbox(
                            checkColor: Colors.black,
                            onChanged: null,
                            value: onSale,
                          ),
                        ),
                        Positioned(
                          left: 0.2,
                          bottom: 3,
                          child: Text('On Sale?'),
                        ),
                        Positioned(
                          top: 43,
                          right: 3,
                          child: getUserInfo(userId),
                        ),
                        Positioned(
                          bottom: 1,
                          right: 3,
                          child: getLocation(storeId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
