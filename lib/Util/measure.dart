
import 'package:flutter/cupertino.dart';

class Measure {

  static double screenHeightFraction(BuildContext context, double fraction) {

    return MediaQuery.of(context).size.height * fraction;
  }

  static double screenWidthFraction(BuildContext context, double fraction) {

    return MediaQuery.of(context).size.width * fraction;
  }
  
  static double fullScreenHeight(BuildContext context) {

    return MediaQuery.of(context).size.height;
  }

  static double fullScreenWidth(BuildContext context) {

    return MediaQuery.of(context).size.width;
  }
}