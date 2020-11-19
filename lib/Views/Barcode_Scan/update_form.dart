import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'package:provider/provider.dart';

class UpdateForm extends StatefulWidget {
  final String storeId;
  final String itemId;

  UpdateForm({this.storeId, this.itemId});

  @override
  _UpdateFormState createState() => _UpdateFormState();
}

class _UpdateFormState extends State<UpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final List<bool> onsales = [true, false];

  //form value
  double _price;
  bool saleOrNot;

  bool _isNumeric(String result) {
    if (result == null) {
      return false;
    }
    return double.tryParse(result) != null;
  }

  //mask the dropdown menu for user friendly purpose.
  String yesOrNo(bool choice) {
    if (choice) {
      return 'Yes';
    } else {
      return 'No';
    }
  }

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
              'Update Item Price',
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
              //initialValue: '0.00',
              decoration: InputDecoration(
                hintText: 'Enter New Price',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
              ],
              onChanged: (val) => setState(() => _price = double.parse(val)),
              validator: (val) {
                if (!_isNumeric(val)) {
                  return 'Please Enter a Number';
                } else if (val.isEmpty || val == '') {
                  return 'Please Enter a Price';
                }
                return null;
              }),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<bool>(
              hint: Text('On Sale?'),
              value: saleOrNot,
              items: onsales.map((choice) {
                return DropdownMenuItem(
                    child: Text(yesOrNo(choice)), value: choice);
              }).toList(),
              onChanged: (value) {
                setState(() {
                  saleOrNot = value;
                });
              },
              validator: (val) {
                if (val == null) {
                  return 'Please Select Yes or No';
                }
                return null;
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
                //color: Theme.of(context).accentColor,
                child: Text('Update Price'),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    await DatabaseService(uid: user.uid).updateItem(
                        widget.storeId,
                        widget.itemId,
                        _price,
                        saleOrNot,
                        user.uid);
                    await DatabaseService(uid: user.uid)
                        .updateRankPoints(1, user.uid);
                    Navigator.pop(context);
                  }
                }),
          )
        ],
      ),
    );
  }
}
