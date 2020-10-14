import 'package:flutter/material.dart';
import 'package:shopping_app/Database/auth_state.dart';

//some of the idea of the form was borrowed from below tutorial's url
//https://github.com/iamshaunjp/flutter-firebase/blob/lesson-10/brew_crew/lib/screens/home/home.dart

class SignIn extends StatefulWidget {
  final Function changeViews;

  SignIn({this.changeViews});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  //set the user input email and password
  String email = '';
  String password = '';

  //error msg shown when sign in is failed
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In'), actions: [
        FlatButton.icon(
          onPressed: () {
            //if pressed, it will show register screen
            widget.changeViews();
            //print();
          },
          icon: Icon(Icons.person),
          label: Text('Register'),
        )
      ]),
      body: Form(
        key: _formKey,
        child: Column(children: <Widget>[
          SizedBox(
            height: 30,
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'E-mail',
            ),
            validator: (value) => value.isEmpty ? 'please enter email' : null,
            onChanged: (val) {
              setState(() {
                email = val;
              });
            },
          ),
          SizedBox(
            height: 30,
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Password(at least 6 characters)',
            ),
            validator: (value) =>
                value.length < 6 ? 'please enter at least 6 characters' : null,
            obscureText: true,
            onChanged: (val) {
              setState(() {
                password = val;
              });
            },
          ),
          SizedBox(
            height: 30,
          ),
          RaisedButton(
            child: Text('sign in'),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                dynamic result =
                    await _auth.signInWithEmailPassword(email, password);
                if (result == null) {
                  setState(() {
                    error = 'sign in failed';
                  });
                }
              }
            },
          ),
          SizedBox(
            child: Text(error),
          ),
        ]),
      ),
    );
  }
}
