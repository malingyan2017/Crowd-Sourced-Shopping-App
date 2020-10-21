import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final String title;
  final Size preferredSize;

  MyAppBar(this.title, {Key key})
      : preferredSize = Size.fromHeight(55.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.blue[200],
      iconTheme: new IconThemeData(
        color: Colors.black,
      ),
      actions: <Widget>[
        Icon(
          Icons.shopping_cart,
          size: 32,
        ),
      ],
    );
  }
}
