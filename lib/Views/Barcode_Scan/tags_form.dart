import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/the_user.dart';

class TagsForm extends StatefulWidget {
  final String barcode;

  TagsForm({this.barcode});

  @override
  _TagsFormState createState() => _TagsFormState();
}

class _TagsFormState extends State<TagsForm> {
  final _formKey = GlobalKey<FormState>();
  String _tag;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    return StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getItemStream(widget.barcode),
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot data = snapshot.data.docs[index];
              var tags = data['tags'];
              var itemId = data.id;
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
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(hintText: 'enter tag'),
                            validator: (val) {
                              if (tags.contains(val)) {
                                return 'tag already exists';
                              }
                              if (val.isEmpty) {
                                return 'please enter a tag';
                              }
                              return null;
                            },
                            onChanged: (val) => setState(() => _tag = val),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          RaisedButton(
                              child: Text('add tag'),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  await DatabaseService().addTag(_tag, itemId);
                                }
                                await DatabaseService(uid: user.uid)
                                    .updateRankPoints(1, user.uid);
                              })
                        ],
                      ))
                ],
              );
            },
          );
        });
  }
}
