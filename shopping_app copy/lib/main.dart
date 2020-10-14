import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/Database/auth_state.dart';
import 'package:shopping_app/Database/decider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shopping_app/Models/the_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of application.

  @override
  Widget build(BuildContext context) {
    return StreamProvider<TheUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        home:
            Decider(), //let this widget decide to show home screen or authenticate screen
      ),
    );
  }
}
