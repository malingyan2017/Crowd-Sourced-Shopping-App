import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Views/Common/base_app.dart';
import 'package:shopping_app/Views/Reviews/add_review.dart';

// https://stackoverflow.com/questions/54751007/cloud-functions-for-firestore-accessing-parent-collection-data
// https://flutterawesome.com/a-simple-ratingbar-for-flutter-which-also-include-a-rating-bar-indicator/

class StoreReviews extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final StoreData ldata;
  StoreReviews({this.ldata});
  static const String appBarTitle = 'Store Reviews';

  @override
  Widget build(BuildContext context) {
    // Text Widget for to Bold username
    Text reviewInfoText(String text) {
      return Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // Widget to style store data such as name and address
    Padding storeText(String text) {
      return Padding(
        padding: EdgeInsets.only(top: 10.0, left: 10.0),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey[850],
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Widget for error message styling
    /* Padding errorMessages(String text) {
      return Padding(
        padding: EdgeInsets.only(top: 10.0, left: 10.0),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.redAccent[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }*/

    // Widget to run query to retrieve location info such as store name, address, city and zip code
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
                  '\n' +
                  locationData['streetAddress'] +
                  '\n' +
                  locationData['city'] +
                  ', ' +
                  locationData['state'] +
                  ' ' +
                  locationData['zipCode'];
            } else {
              message = "LOADING";
            }

            return storeText(message);
          });
    }

    // Widget for the header bar that contains store information and the add review button
    Widget reviewHeader(String locationID, StoreData storedata) {
      return Container(
        height: 75,
        width: double.infinity,
        color: Colors.grey[300],
        child: Stack(
          children: <Widget>[
            getLocation(locationID),
            Padding(
              padding: EdgeInsets.only(top: 10.0, left: 275),
              child: FlatButton.icon(
                textColor: Colors.black,
                color: Colors.blue[200],
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddReview(data: storedata)),
                  );
                },
                icon: Icon(Icons.add, size: 18),
                label: Text("Add Review"),
              ),
            ),
            // In case I add average reviews feature on the header bar (TBD)
            /*Padding(
              padding: EdgeInsets.only(top: 70.0, left: 10),
              child: Text(
                'Average Rating:',
                style: TextStyle(
                  color: Colors.grey[850],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 65.0, left: 125.0),
              child: RatingBarIndicator(
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                rating: 5,
                itemCount: 5,
                itemSize: 25.0,
              ),
            ),*/
          ],
        ),
      );
    }

    // Widget to retrieve user information such as rank and username for the individual review
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
              reviewInfoText(message);
            }
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> userData = snapshot.data.data();

              int userPoints = userData['rankPoints'];
              String userRank = db.getUserRank(userPoints);
              Icon icon = db.getRankIcon(userPoints);
              String user = userData['username'] + ' ';
              //String rank = ' (' + userRank + ')';
              return Row(
                children: <Widget>[
                  reviewInfoText(user),
                  icon,
                  //reviewInfoText(rank)
                ],
              );
            } else {
              message = "LOADING";
              return reviewInfoText(message);
            }
          });
    }

    return Scaffold(
        // Stream builder to review the user's preferred store location ID, so that
        // the reviews for that store can be retrieved

        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            appBarTitle,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.blue[200],
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.home),
              iconSize: 32,
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => BaseApp()));
              },
            ),
          ],
        ),
        body:
            // Stream builder to listen to latest user reviews that have been added
            StreamBuilder<QuerySnapshot>(
          stream: DatabaseService().getStoreReviewsStream(ldata.sId),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.active &&
                snapshot.hasError) {
              return Text("Something went wrong review stream");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              int numReviews = snapshot.data.docs.length;
              print(numReviews);

              return Container(
                child: Stack(
                  children: <Widget>[
                    reviewHeader(ldata.sId, ldata),
                    Padding(
                      padding: EdgeInsets.only(top: 85.0),
                      child: ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot revdata = snapshot.data.docs[index];
                          print(revdata);

                          // Variables for user rating and formatted date stamp for review
                          int rating = revdata['rating'];
                          Timestamp timestamp = revdata['date_created'];
                          DateTime myDateTime =
                              DateTime.parse(timestamp.toDate().toString());
                          String formattedDateTime =
                              DateFormat('MM-dd-yyyy').format(myDateTime);
                          //int userPoints = revdata['rankPoints'];

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
                                        padding: EdgeInsets.only(
                                            left: 8.0, bottom: 25.0),
                                        child: getUserInfo(revdata),
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
                                    padding:
                                        EdgeInsets.only(left: 65.0, top: 27.0),
                                    child: RatingBarIndicator(
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      rating: rating.toDouble(),
                                      itemCount: 5,
                                      itemSize: 17.0,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 10.0, top: 70.0),
                                    child: Text('${revdata['body']}\n'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ));
  }
}
