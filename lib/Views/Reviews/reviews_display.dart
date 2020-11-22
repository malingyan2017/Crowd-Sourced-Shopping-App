import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Views/Common/base_app.dart';
import 'package:shopping_app/Views/Reviews/add_review.dart';
import 'package:shopping_app/Views/Reviews/edit_review.dart';
import 'package:shopping_app/Models/review.dart';

// https://stackoverflow.com/questions/54751007/cloud-functions-for-firestore-accessing-parent-collection-data
// https://flutterawesome.com/a-simple-ratingbar-for-flutter-which-also-include-a-rating-bar-indicator/

class StoreReviews extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final StoreData ldata;
  StoreReviews({this.ldata});
  static const String appBarTitle = 'Store Reviews';

  @override
  Widget build(BuildContext context) {
    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);
    String myCurrentUserId = auth.currentUser.uid;

    print('current user: $myCurrentUserId');
    // Text Widget to Bold username
    Text reviewInfoText(String text) {
      return Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // Widget to style store name
    Text storeName(String text) {
      return Text(
        text,
        style: TextStyle(
          color: Colors.grey[850],
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      );
    }

    // Widget to style store address
    Text storeText(String text) {
      return Text(
        text,
        style: TextStyle(
          color: Colors.grey[850],
        ),
      );
    }

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
              return storeText(message);
            }

            if (snapshot.hasData &&
                snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> locationData = snapshot.data.data();
              String name = locationData['name'];
              message = locationData['streetAddress'] +
                  '\n' +
                  locationData['city'] +
                  ', ' +
                  locationData['state'] +
                  ' ' +
                  locationData['zipCode'];
              return Column(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  storeName(name),
                  storeText(message),
                ],
              );
            } else {
              message = "LOADING";
              return storeText(message);
            }
          });
    }

    // Widget for the header bar that contains store information and the add review button
    Widget reviewHeader(
        String locationID, StoreData storedata, int ratingSum, int numReviews) {
      double avgRating = 0;
      if (numReviews > 0) {
        avgRating = ratingSum / numReviews;
      }
      return Container(
        height: 105,
        width: double.infinity,
        color: Colors.grey[300],
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0, left: 10),
              child: getLocation(locationID),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, left: 295),
              child: RaisedButton(
                  textColor: Colors.black,
                  color: Theme.of(context).buttonColor,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddReview(data: storedata)),
                    );
                  },
                  child: Text('Add Review')),
            ),

            // In case I add average reviews feature on the header bar (TBD)
            Padding(
              padding: EdgeInsets.only(top: 68.0, left: 10.0),
              child: RatingBarIndicator(
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                rating: avgRating,
                itemCount: 5,
                itemSize: 25.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 73.0, left: 140),
              child: Text(
                '($numReviews)',
                style: TextStyle(
                  color: Colors.grey[850],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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

              // Calculate User's rank and retrieve icon
              int userPoints = userData['rankPoints'];
              Icon icon = db.getRankIcon(userPoints);
              String user = userData['username'] + ' ';

              return Row(
                children: <Widget>[
                  reviewInfoText(user),
                  icon,
                ],
              );
            } else {
              message = "LOADING";
              return reviewInfoText(message);
            }
          });
    }

    return Scaffold(
        // Home icon to allow users to easily navigate back to the home page
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            appBarTitle,
          ),
          centerTitle: true,
        ),
        body:
            // Stream builder to listen to latest user reviews that have been added
            // for the selected store
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

              // Get the sum of the total rating so that the average rating can be calculated
              // https://stackoverflow.com/questions/62722560/how-to-calculate-the-sum-of-a-particular-field-of-all-the-documents-in-a-collect

              int totalRating = 0;

              if (numReviews > 0) {
                var ds = snapshot.data.docs;
                for (int i = 0; i < numReviews; i++) {
                  totalRating += (ds[i]['rating']);
                }
              }

              print('rating sum $totalRating');

              return Container(
                child: Stack(
                  children: <Widget>[
                    reviewHeader(ldata.sId, ldata, totalRating, numReviews),
                    Padding(
                      padding: EdgeInsets.only(top: 110.0),
                      child: ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot revdata = snapshot.data.docs[index];
                          Map<String, dynamic> reviewMap = revdata.data();

                          // Boolean variables for edit/delete button and edit date
                          bool editDeleteBut = false;
                          bool isEdited = false;

                          // Variables for user rating and formatted date stamp for review
                          int rating = revdata['rating'];
                          String revUserId = revdata['user_id'];
                          Timestamp timestamp = revdata['date_created'];
                          DateTime myDateTime =
                              DateTime.parse(timestamp.toDate().toString());
                          String formattedDateTime =
                              DateFormat('MM-dd-yyyy').format(myDateTime);

                          // Variables for formatted date for edited date
                          String formattedDateTimeEdit;

                          if (reviewMap['date_edited'] != null) {
                            isEdited = true;
                            Timestamp timestampedit = revdata['date_edited'];
                            DateTime myDateTimeEdit = DateTime.parse(
                                timestampedit.toDate().toString());
                            formattedDateTimeEdit =
                                DateFormat('MM-dd-yyyy').format(myDateTimeEdit);
                          }

                          // Review object instance to hold data for when user
                          // wants to edit data
                          Review reviewData = Review(
                              id: revdata.id,
                              userId: revdata['user_id'],
                              rating: rating,
                              body: revdata['body'],
                              dateCreated: myDateTime);

                          // Check if the review belongs to the logged-in user, so that edit/delete button can be added
                          if (myCurrentUserId == revUserId) {
                            editDeleteBut = true;
                          }

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
                                  if (isEdited)
                                    Positioned(
                                      bottom: 2,
                                      right: 3,
                                      child: Stack(
                                        children: <Widget>[
                                          Text('Edited: $formattedDateTimeEdit',
                                              style: TextStyle(
                                                fontSize: 10,
                                              )),
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
                                  Positioned(
                                    left: 315,
                                    top: 20,
                                    child: Row(
                                      children: <Widget>[
                                        if (editDeleteBut)
                                          IconButton(
                                              icon: Icon(Icons.edit),
                                              iconSize: 25,
                                              color: Colors.grey,
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditReview(
                                                            sId: ldata.sId,
                                                            rdata: reviewData),
                                                  ),
                                                );
                                              }),
                                        if (editDeleteBut)
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            iconSize: 25,
                                            color: Colors.grey,
                                            onPressed: () {
                                              // Delete Review from delete button
                                              db.deleteReview(
                                                  ldata.sId, revdata.id);

                                              Scaffold.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Review has been Deleted.'),
                                              ));
                                            },
                                          ),
                                      ],
                                    ),
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
