import 'package:flutter/material.dart';
// Comes directly from the code used by Jasmine
class HelpIcon extends StatelessWidget {

  final String message;
  final int secondsToShow;

  HelpIcon({Key key, this.message, this.secondsToShow = 2}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      height: 75,
      margin: EdgeInsets.all(15.0),
      child: IconButton(
        icon: Icon(Icons.help),
        iconSize: 25,
        color: Colors.black54,
        onPressed: () {},
      ),
      showDuration: Duration(seconds: secondsToShow),
    );
  }
}