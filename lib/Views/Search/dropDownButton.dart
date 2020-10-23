import 'package:flutter/material.dart';

class MyDropDownButton extends StatefulWidget {
  @override
  _MyDropDownButtonState createState() => _MyDropDownButtonState();
}

class _MyDropDownButtonState extends State<MyDropDownButton> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      hint: Text('quantity'),
      value: quantity,
      onChanged: (value) {
        setState(() {
          quantity = value;
        });
      },
      items: <int>[1, 2, 3, 4, 5, 6, 7].map<DropdownMenuItem<int>>((quantity) {
        return DropdownMenuItem<int>(
          child: Text(quantity.toString()),
          value: quantity,
        );
      }).toList(),
    );
  }
}
