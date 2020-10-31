import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/Database/database.dart';

class TagsForm extends StatefulWidget {
  final String barcode;

  TagsForm({this.barcode});

  @override
  _TagsFormState createState() => _TagsFormState();
}

class _TagsFormState extends State<TagsForm> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getItemStream(widget.barcode),
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot data = snapshot.data.docs[index];
              var tags = data['tags'];
              return Column(
                children: [
                  Text('Popular tags for this item:'),
                  Row(
                    children: [
                      for (var item in tags)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item),
                        ),
                    ],
                  ),
                ],
              );
            },
          );
        });
  }
}
