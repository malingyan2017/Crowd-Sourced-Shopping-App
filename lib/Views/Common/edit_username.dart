import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/Components/centered_loading_circle.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Util/measure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateUser extends StatelessWidget {
  static const String routeName = '/updateUser';
  static const String appBarTitle = 'Edit Username';
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    //CollectionReference myUser = FirebaseFirestore.instance.collection('users');
    //where('uid', isEqualTo: auth.currentUser.uid);
    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);

    return Scaffold(
      //drawer: new SideDrawer(),
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: db.getUserStream(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          else if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data.data();

            //return Text("Username: ${data['username']}");
            return _UsernameForm(data: data,);
          }
          else {
            return CenteredLoadingCircle(
              height: Measure.screenHeightFraction(context, .2),
              width: Measure.screenWidthFraction(context, .4),
            );
          }
        },
      ),
    );
  }
}

class _UsernameForm extends StatefulWidget {

  final Map<String, dynamic> data;

  _UsernameForm({Key key, this.data}): super(key: key);

  @override
  _UsernameFormState createState() => _UsernameFormState();
}

// https://flutter.dev/docs/cookbook/forms/validation
class _UsernameFormState extends State<_UsernameForm> {

  final FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  static const String hintText = 'Type New Username';
  static const String labelText = 'New Username';
  static const String databaseErrorMessage = 
    'An error occurred while changing the username.';
  static const int maxLength = 16;

  bool databaseErrorOccurred = false;
  bool usernameTaken = false;
  bool usernameChanged = false;
  String previousUsername;

  String getErrorMessage(String username) {

    return usernameTaken ? 
    'The username "$username" is taken.\nPlease provide another username.'
    : databaseErrorMessage;
  }

  @override
  Widget build(BuildContext context) {

    // https://flutter.dev/docs/cookbook/forms/retrieve-input
    // The text controller logic is almost directly from the documentation
    TextEditingController usernameController = TextEditingController();

    @override
    void dispose() {
      // Clean up the controller when the widget is disposed.
      usernameController.dispose();
      super.dispose();
    }

    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);

    Widget usernameContainer = Container(
      child: Text(
        'Your current username is:\n${widget.data['username']}',
        style: Theme.of(context).textTheme.headline6,
      ),
    );

    List<Widget> columnChildren = [
      usernameContainer,
      TextFormField(
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText
        ),
        controller: usernameController,
        validator: (value) {
          if (value.isEmpty || value == '') {
            return 'Please provide a username before submitting.';
          }
          else if (value.contains(RegExp(r'\s'))) {
            // https://api.dart.dev/stable/2.10.2/dart-core/RegExp-class.html
            // https://www.regular-expressions.info/shorthand.html
            return 'Please provide a username without whitespace characters.';
          }
          return null;
        },
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () async {
                usernameChanged = false;
                databaseErrorOccurred = false;
                usernameTaken = false;
                
                if (_formKey.currentState.validate()) {

                  usernameTaken = await db.usernameExists(usernameController.text);
                  if (!usernameTaken) {
                    await db.updateUsername(usernameController.text)
                    .catchError( (error) {
                      databaseErrorOccurred = true;
                    });

                    if (!databaseErrorOccurred) {
                      // If we make it this far then we've managed to change
                      // their username without issues      
                      usernameChanged = true;
                    }
                  }
                }
                
                previousUsername = usernameController.text;
                setState(() {});
              }, 
              child: Text('Submit')
            ),
          ],
        ),
      )
    ];

    if (databaseErrorOccurred || usernameTaken || usernameChanged) {
      Widget messageText;

      if (usernameTaken) {
        messageText = Text(
          getErrorMessage(previousUsername),
          style: TextStyle(color: Colors.red)
        );
      }
      else if (usernameChanged) {
        messageText = Text(
          'Your username was successfully changed to "$previousUsername".',
          style: TextStyle(color: Colors.green)
        );
      }

      Widget usernameMessage = Container(
          child: messageText
      );

      columnChildren.add(usernameMessage);
    }

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columnChildren,
        ),
      )
    );
  }

}