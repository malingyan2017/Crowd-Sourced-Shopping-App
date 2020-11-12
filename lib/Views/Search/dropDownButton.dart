import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'package:shopping_app/Database/database.dart';

class MyDropDownButton extends StatefulWidget {
  final DocumentSnapshot data;
  final String docId;

  MyDropDownButton({this.data, this.docId});

  @override
  _MyDropDownButtonState createState() => _MyDropDownButtonState();
}

class _MyDropDownButtonState extends State<MyDropDownButton> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    return Column(
      children: [
        DropdownButton<int>(
          hint: Text('quantity'),
          value: quantity,
          onChanged: (value) {
            setState(() {
              quantity = value;
            });
          },
          items:
              <int>[1, 2, 3, 4, 5, 6, 7].map<DropdownMenuItem<int>>((quantity) {
            return DropdownMenuItem<int>(
              child: Text(quantity.toString()),
              value: quantity,
            );
          }).toList(),
        ),
        RaisedButton(
            color: Colors.blue[200],
            child: Text('add to cart'),
            onPressed: () async {
              await DatabaseService(uid: user.uid).addToCart(
                widget.docId,
                widget.data['name'],
                widget.data['pictureUrl'],
                quantity,
                widget.data['barcode'],
              );
            }),
      ],
    );
  }
}
