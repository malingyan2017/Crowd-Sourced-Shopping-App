import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/Models/review.dart';
import 'package:shopping_app/Views/Common/base_app.dart';
import "dart:async";

// References: https://pub.dev/packages/flutter_rating_bar
// https://flutter.dev/docs/cookbook/forms/validation
// https://stackoverflow.com/questions/49351648/how-do-i-disable-a-button-in-flutter
// https://medium.com/flutter-community/simple-ways-to-pass-to-and-share-data-with-widgets-pages-f8988534bd5b

class EditReview extends StatelessWidget {
  final Review rdata;

  final String sId;
  EditReview({this.sId, this.rdata});

  static const String appBarTitle = 'Edit Review';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          appBarTitle,
        ),
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
      body: Stack(
        children: <Widget>[
          MyCustomForm(sId: sId, rdata: rdata),
        ],
      ),
    );
  }
}

// Create a Form widget for the Review Page.
class MyCustomForm extends StatefulWidget {
  final Review rdata;

  final String sId;
  MyCustomForm({this.sId, this.rdata});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState(sId: sId, rdata: rdata);
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Review rdata;

  final String sId;
  MyCustomFormState({this.sId, this.rdata});
  final _formKey = GlobalKey<FormState>();

  int _myRating;
  String revBody;

  // Function to validate the form data after hitting submit
  void validateForm() {
    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);
    if (_formKey.currentState.validate()) {
      // Check if the rating value has changed
      int ratingVal;
      if (_myRating == null) {
        ratingVal = rdata.rating;
      } else {
        ratingVal = _myRating;
      }
      Review reviewData = Review(
        id: rdata.id,
        userId: rdata.userId,
        rating: ratingVal,
        body: revBody,
        dateEdited: DateTime.now(),
      );
      // If data is valid, add data into database
      db.updateStoreReview(sId, reviewData);

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('A Review has been Updated.'),
      ));
      // https://stackoverflow.com/questions/49072957/flutter-dart-open-a-view-after-a-delay
      Timer(Duration(seconds: 2), () {
        // 5s over, navigate to a new page
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Align(
              alignment: Alignment.topCenter,
              // Widget for the rating bar
              child: RatingBar(
                initialRating: rdata.rating.toDouble(),
                minRating: 1,
                unratedColor: Colors.amber[100],
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _myRating = rating.toInt();
                  });
                },
              ),
            ),
          ),
          // Widget for the text box
          TextFormField(
            maxLines: 5,
            autocorrect: true,
            maxLength: 255,
            initialValue: rdata.body,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              helperText: 'Tell us about your experience at this store.',
            ),
            validator: (String value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              if (value.length > 255) {
                return 'Your review exceeds 255 characters.';
              }
              revBody = value;
              return null;
            },
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
            child: RaisedButton(
              color: Theme.of(context).buttonColor,
              onPressed: () => validateForm(),
              //onPressed: () => null,
              child: Text('Update'),
            ),
          ),
        ],
      ),
    );
  }
}
