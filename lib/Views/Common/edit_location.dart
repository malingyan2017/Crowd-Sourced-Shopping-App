import 'package:flutter/material.dart';
import 'package:shopping_app/Views/Common/app_bar.dart';
import 'package:shopping_app/Views/Common/base_app.dart';
import 'package:shopping_app/Views/Common/side_drawer.dart';

class UpdateLocation extends StatelessWidget {
  static const String routeName = '/editLocation';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: new SideDrawer(),
      appBar: MyAppBar('Edit Location'),
    );
  }
}
