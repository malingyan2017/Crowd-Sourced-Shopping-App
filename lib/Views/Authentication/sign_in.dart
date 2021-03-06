import 'package:flutter/material.dart';
import 'package:shopping_app/Database/auth_state.dart';
import 'package:shopping_app/Components/centered_loading_circle.dart';

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

  //check if should present loading page
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? CenteredLoadingCircle()
        : Scaffold(
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
                        value.isEmpty ? 'Please Enter Email' : null,
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
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value.length < 6
                        ? 'Please Enter At Least 6 Characters'
                        : null,
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
                    child: Text('Sign In'),
                    textColor: Colors.black,
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          loading = true;
                        });
                        dynamic result = await _auth.signInWithEmailPassword(
                            email, password);
                        if (result == null) {
                          setState(() {
                            error =
                                'Please Double Check Email Address and Password';
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
                  ),
                ]),
              ),
            ),
          );
  }
}
