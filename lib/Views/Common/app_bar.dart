import 'package:flutter/material.dart';
import 'package:shopping_app/Views/Shopping_List/shopping_list.dart';

class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final String title;
  final Size preferredSize;

  MyAppBar(this.title, {Key key})
      : preferredSize = Size.fromHeight(55.0),
        super(key: key);

  // https://api.flutter.dev/flutter/material/AppBar-class.html
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.blue[200],
      iconTheme: new IconThemeData(
        color: Colors.black,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.shopping_cart),
          iconSize: 32,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => ShoppingList()
              )
            );
          },
        ),
      ],
    );
  }
}
