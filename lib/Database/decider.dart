import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'package:shopping_app/Views/home.dart';
import 'package:shopping_app/Views/authenticate.dart';

class Decider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //either return home or authenticate widget
    //depending on if user is signed in

    //get user from stream provider
    final user = Provider.of<TheUser>(context);
    //print(user);

    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
