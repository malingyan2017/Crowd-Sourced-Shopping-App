import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/the_user.dart';

class TagsForm extends StatefulWidget {
  final dynamic tags;
  final String itemId;

  TagsForm({this.tags, this.itemId});

  @override
  _TagsFormState createState() => _TagsFormState();
}

class _TagsFormState extends State<TagsForm> {
  final _formKey = GlobalKey<FormState>();
  String _tag;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(hintText: 'enter tag'),
            validator: (val) {
              if (widget.tags.contains(val)) {
                return 'tag already exists';
              }
              if (val.isEmpty) {
                return 'please enter a tag';
              }
              return null;
            },
            onChanged: (val) => setState(() => _tag = val),
          ),
          SizedBox(height: 20),
          RaisedButton(
              child: Text('add tag'),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  await DatabaseService().addTag(_tag, widget.itemId);
                }
                await DatabaseService(uid: user.uid)
                    .updateRankPoints(1, user.uid);
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }
}
