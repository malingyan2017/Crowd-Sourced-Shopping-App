
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Measure {

  // Has a lower limit defined by kMinInteractiveDimension
  static double screenHeightFraction(BuildContext context, double fraction) {

    double measurement = MediaQuery.of(context).size.height * fraction;
    return measurement >= kMinInteractiveDimension 
      ? measurement
      : kMinInteractiveDimension;
  }

  // Has a lower limit defined by kMinInteractiveDimension
  static double screenWidthFraction(BuildContext context, double fraction) {

    double measurement = MediaQuery.of(context).size.width * fraction;

    return measurement >= kMinInteractiveDimension 
      ? measurement
      : kMinInteractiveDimension;
  }
  
  static double fullScreenHeight(BuildContext context) {

    return MediaQuery.of(context).size.height;
  }

  static double fullScreenWidth(BuildContext context) {

    return MediaQuery.of(context).size.width;
  }
}