import 'package:flutter/material.dart';
import 'package:shopping_app/Views/register.dart';
import 'package:shopping_app/Views/sign_in.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool viewSignIn = true;

  //set the state to check if return sign in or register page
  void changeViews() {
    setState(() => viewSignIn = !viewSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if (viewSignIn) {
      return SignIn(changeViews: changeViews);
    } else {
      return Register(changeViews: changeViews);
    }
  }
}
