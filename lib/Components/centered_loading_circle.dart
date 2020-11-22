import 'package:flutter/material.dart';
import 'package:shopping_app/Util/measure.dart';

// https://stackoverflow.com/questions/51901379/how-to-set-size-to-circularprogressindicator/51901451
class CenteredLoadingCircle extends StatelessWidget {

  final double height;
  final double width;

  CenteredLoadingCircle({Key key, this.height, this.width}): super(key: key);

  @override
  Widget build(BuildContext context) {

    return Center(
      child: SizedBox(
        height: height ?? Measure.screenHeightFraction(context, .2),
        width: width ?? Measure.screenWidthFraction(context, .4),
        child: CircularProgressIndicator()
      ),
    );
  }
}