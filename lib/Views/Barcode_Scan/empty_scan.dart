import 'package:flutter/material.dart';

class EmptyScan extends StatefulWidget {
  final String storeName;
  final String storeZipcode;

  EmptyScan({this.storeName, this.storeZipcode});

  @override
  _EmptyScanState createState() => _EmptyScanState();
}

class _EmptyScanState extends State<EmptyScan> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your current store: ',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        Text('${widget.storeName} with zipcode ${widget.storeZipcode}'),
        SizedBox(
          height: 20,
        ),
        Text(
          'To change location, please navigate to upper left icon',
          style: TextStyle(color: Colors.blue),
        ),
      ],
    );
  }
}
