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

class AddReview extends StatelessWidget {
  final StoreData data;
  AddReview({this.data});

  static const String appBarTitle = 'Add Review';

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
          MyCustomForm(data: data),
        ],
      ),
    );
  }
}

// Create a Form widget for the Review Page.
class MyCustomForm extends StatefulWidget {
  final StoreData data;
  MyCustomForm({this.data});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState(data: data);
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  final StoreData data;
  MyCustomFormState({this.data});
  final FirebaseAuth auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  int _myRating = 0;
  String revBody;
  bool _buttonEnabled = false;

  // Function to validate the form data after hitting submit
  void validateForm() {
    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);
    String myCurrentUserId = auth.currentUser.uid;
    print('add rev user: $myCurrentUserId');
    if (_formKey.currentState.validate()) {
      Review reviewData = Review(
          userId: myCurrentUserId,
          rating: _myRating,
          body: revBody,
          dateCreated: DateTime.now());

      // If data is valid, add data into database
      db.addStoreReview(data.sId, reviewData);

      // Update Rank points by 1 for every new review
      db.updateRankPoints(1, reviewData.userId);

      // Confimration message for review addition
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('A Review has been Added.'),
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
                initialRating: 0,
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
                    _buttonEnabled = true;
                    print(_myRating);
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
            decoration: InputDecoration(
              hintText: 'Enter a review . . .',
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
              color:
                  _buttonEnabled ? Theme.of(context).buttonColor : Colors.grey,
              onPressed: _buttonEnabled ? () => validateForm() : null,
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
