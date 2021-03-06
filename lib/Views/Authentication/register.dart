import 'package:flutter/material.dart';
import 'package:shopping_app/Database/auth_state.dart';
import 'package:shopping_app/Components/centered_loading_circle.dart';

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
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? CenteredLoadingCircle()
        : Scaffold(
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
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://uago.at/-o0SC/sgim.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'E-mail',
                      border: OutlineInputBorder(),
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
                      hintText: 'Password(At Least 6 Characters)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value.length < 6 ? 'Enter At Least 6 Characters' : null,
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
                    textColor: Colors.black,
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          loading = true;
                        });
                        dynamic result = await _auth.registerWithEmailPassword(
                            email, password);
                        if (result == null) {
                          setState(() {
                            error =
                                'Register Failed: Please Provide a Valid Email';
                            loading = false;
                          });
                        }
                      }
                    },
                  ),
                  SizedBox(
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                ]),
              ),
            ),
          );
  }
}
