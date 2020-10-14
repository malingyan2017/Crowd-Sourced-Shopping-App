import 'package:flutter/material.dart';
import 'package:shopping_app/Database/auth_state.dart';

//some of the idea of the form was borrowed from below tutorial's url
//https://github.com/iamshaunjp/flutter-firebase/blob/lesson-10/brew_crew/lib/screens/home/home.dart

class Register extends StatefulWidget {
  final Function changeViews;
  Register({this.changeViews});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  //take user input as email and password
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        actions: [
          FlatButton.icon(
            //if pressed, it will show sign in screen
            onPressed: () {
              widget.changeViews();
            },
            icon: Icon(Icons.person),
            label: Text('Sign In'),
          )
        ],
      ),
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
            validator: (value) =>
                value.isEmpty ? 'Please enter an email' : null,
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
                value.length < 6 ? 'enter at lease 6 characters' : null,
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
            child: Text('Register'),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                dynamic result =
                    await _auth.registerWithEmailPassword(email, password);
                if (result == null) {
                  setState(() {
                    error = 'register failed';
                  });
                }
              }
            },
          ),
          SizedBox(
            child: Text(error),
          )
        ]),
      ),
    );
  }
}
