import 'package:flutter/material.dart';

ThemeData myTheme() {
  var myPrimaryColor = Color(0xff0088cc);
  var myAccentColor = Color(0xff16b6f0);

  return ThemeData(
    brightness: Brightness.light,
    primaryColor: myPrimaryColor,
    accentColor: myAccentColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.black,
        primary: Colors.grey[300],
      ),
    ),
    buttonColor: Colors.grey[300],
    appBarTheme: AppBarTheme(
      centerTitle: true,
      textTheme: TextTheme(
        headline6: TextStyle(
          fontSize: 22.0,
          color: Colors.black,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.black,
        size: 32,
      ),
      actionsIconTheme: IconThemeData(
        color: Colors.black,
        size: 32,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      unselectedIconTheme: IconThemeData(
        color: Colors.black,
        size: 32,
        opacity: .5,
      ),
      selectedIconTheme:
          IconThemeData(color: myPrimaryColor, size: 32, opacity: 1),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
    ),
  );
}
