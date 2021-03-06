import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const int maxLength = 10;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<TheUser>(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Update Tags',
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: 'Enter new tag',
              border: OutlineInputBorder(),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z]+|\s"))
            ],
            validator: (val) {
              if (widget.tags.contains(val)) {
                return 'Tag Already Exists';
              }
              if (val.isEmpty || val == '') {
                return 'Please Enter a Tag';
              }
              if (val.length > maxLength) {
                return 'Please Only Enter $maxLength Characters';
              }

              return null;
            },
            onChanged: (val) => setState(() => _tag = val),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
                //color: Theme.of(context).buttonColor,
                child: Text('Add Tag'),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    await DatabaseService().addTag(_tag, widget.itemId);
                    await DatabaseService(uid: user.uid)
                        .updateRankPoints(1, user.uid);
                    Navigator.pop(context);
                  }
                }),
          ),
        ],
      ),
    );
  }
}
