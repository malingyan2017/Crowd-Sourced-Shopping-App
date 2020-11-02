import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

// https://stackoverflow.com/questions/54751007/cloud-functions-for-firestore-accessing-parent-collection-data
// https://flutterawesome.com/a-simple-ratingbar-for-flutter-which-also-include-a-rating-bar-indicator/
// https://github.com/flutter/flutter/issues/15928

class LiveReviews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Text Widget for User Name Bolding
    Text reviewInfoText(String text) {
      return Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // Query for all reviews subcollections for the live feed
    var reviews = FirebaseFirestore.instance
        .collectionGroup('reviews')
        .orderBy('date_created', descending: true)
        .limit(10);

    // Widget to retrieve location info such as store name, city and zip code
    Widget getLocation(String locationID) {
      var userData =
          FirebaseFirestore.instance.collection('stores').doc(locationID).get();

      return FutureBuilder<DocumentSnapshot>(
          future: userData,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            String message;
            if (snapshot.hasError) {
              message = "Something went wrong Location Info";
            }

            if (snapshot.hasData &&
                snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> locationData = snapshot.data.data();
              message = locationData['name'] +
                  ' in ' +
                  locationData['city'] +
                  ', ' +
                  locationData['zipCode'];
            } else {
              message = "LOADING";
            }

            return Text(message);
          });
    }

    // Widget to retrieve user information such as rank and username
    Widget getUserInfo(DocumentSnapshot data) {
      var userData = FirebaseFirestore.instance
          .collection('users')
          .doc(data['user_id'])
          .get();

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

              message = userData['username'] +
                  ' (rank: ' +
                  userData['rank'].toString() +
                  ')';
            } else {
              message = "LOADING";
            }
            return reviewInfoText(message);
          });
    }

    return Scaffold(
      // Stream builder to listen to latest user reviews that have been added
      body: StreamBuilder(
        stream: reviews.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          } else if (snapshot.hasData) {
            return new ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot data = snapshot.data.docs[index];

                // Parent Id of location data
                var storeId = data.reference.parent.parent.id;

                // Variables for user rating and formatted date stamp for review
                int rating = data['rating'];
                Timestamp timestamp = data['date_created'];
                DateTime myDateTime =
                    DateTime.parse(timestamp.toDate().toString());
                String formattedDateTime =
                    DateFormat('MM-dd-yyyy').format(myDateTime);

                return SizedBox(
                  child: Card(
                    child: Stack(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.account_circle,
                              size: 60.0,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0, bottom: 25.0),
                              child: Stack(
                                children: <Widget>[
                                  getUserInfo(data),
                                ],
                              ),
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
                        Padding(
                          padding: EdgeInsets.only(left: 65.0, top: 27.0),
                          child: RatingBarIndicator(
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            rating: rating.toDouble(),
                            itemCount: 5,
                            itemSize: 17.0,
                            // emptyColor: Colors.amber.withAlpha(90),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0, top: 70.0),
                          child: Text('${data['body']}\n\n'),
                        ),
                        Positioned(
                          bottom: 3,
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
