import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'package:shopping_app/Database/database.dart';

import "dart:async";

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
    return Expanded(
      child: Row(
        children: [
          DropdownButton<int>(
            hint: Text('quantity'),
            value: quantity,
            onChanged: (value) {
              setState(() {
                quantity = value;
              });
            },
            items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                .map<DropdownMenuItem<int>>((quantity) {
              return DropdownMenuItem<int>(
                child: Text(quantity.toString()),
                value: quantity,
              );
            }).toList(),
          ),
          SizedBox(width: 100),
          //Positioned(
          // left: 50,
          //child:
          RaisedButton(
            //color: Colors.blue[200],
            child: Text('Add to List'),
            textColor: Colors.black,
            onPressed: () async {
              var result = await DatabaseService(uid: user.uid)
                  .validateQuantity(widget.data['barcode'], quantity);
              if (result == true) {
                await DatabaseService(uid: user.uid).addToCart(
                  widget.docId,
                  widget.data['name'],
                  widget.data['pictureUrl'],
                  quantity,
                  widget.data['barcode'],
                );
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Item(s) Has Been Added.'),
                ));
              } else {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                    'Maxium Quantity is 10 for Each Item',
                    style: TextStyle(color: Colors.red),
                  ),
                ));
              }
            },
          ),
          //),
        ],
      ),
    );
  }
}
