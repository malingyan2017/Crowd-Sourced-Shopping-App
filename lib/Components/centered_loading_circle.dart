import 'package:flutter/material.dart';

// https://stackoverflow.com/questions/51901379/how-to-set-size-to-circularprogressindicator/51901451
class CenteredLoadingCircle extends StatelessWidget {

  final double height;
  final double width;

  CenteredLoadingCircle({Key key, this.height, this.width}): super(key: key);

  @override
  Widget build(BuildContext context) {

    return Center(
      child: SizedBox(
        height: height,
        width: width,
        child: CircularProgressIndicator()
      ),
    );
  }
}