import 'package:flutter/material.dart';
import 'package:shopping_app/Views/Common/side_drawer.dart';
import 'package:shopping_app/Views/Common/app_bar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Compare extends StatefulWidget {
  @override
  _CompareState createState() => _CompareState();
}

class _CompareState extends State<Compare> {
  String zipcode = '97330';

  //items to show when there is items matched to searchName

  @override
  Widget build(BuildContext context) {
    Query stores = FirebaseFirestore.instance
        .collection('stores')
        .where('zipCode', isEqualTo: zipcode);

    return Scaffold(
      appBar: AppBar(
        title: Text('Compare result'),
      ),
      body: Container(),
    );
  }
}
