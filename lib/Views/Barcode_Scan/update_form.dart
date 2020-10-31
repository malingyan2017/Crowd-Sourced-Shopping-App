import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UpdateForm extends StatefulWidget {
  @override
  _UpdateFormState createState() => _UpdateFormState();
}

class _UpdateFormState extends State<UpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final List<bool> onsales = [true, false];

  //form value
  double price;
  String tag;
  List<String> tags = ['one', 'two'];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('update this item'),
          TextFormField(
            decoration: InputDecoration(hintText: 'enter the new price'),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            decoration: InputDecoration(hintText: 'enter a tag for this item'),
            validator: (val) => val.isEmpty ? 'please enter a tag' : null,
          ),
          Text('here are the popular tags:'),
          for (var item in tags) Text(item),
          DropdownButton(items: null, onChanged: null)
        ],
      ),
    );
  }
}
