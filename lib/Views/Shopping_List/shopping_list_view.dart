import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/Components/centered_loading_circle.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/list_item.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'package:shopping_app/Util/measure.dart';
import 'package:shopping_app/Views/Compare/compare.dart';

// Most of the structure for the ui was adapted from Lingyan's work in 
// the item search page.
class ShoppingListView extends StatefulWidget {
  @override
  _ShoppingListViewState createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> {

  // static const String title = 'Shopping List';
  int itemCount = 0;

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<TheUser>(context);
    DatabaseService db = DatabaseService(uid: user.uid);

    return StreamBuilder<QuerySnapshot>(
      stream: db.getShoppingListStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

        Widget bodyToReturn;
        Widget buttonToReturn;

        if (snapshot.hasError) {
          bodyToReturn = Text("Something went wrong");
          // return _ScaffoldTemplate(body: Text("Something went wrong"));
        }
        else if (snapshot.hasData) {
          //Map<String, dynamic> data = snapshot.data.data();

          itemCount = snapshot.data.docs.length;

          bodyToReturn = itemCount == 0 
            ? _EmptyCart() 
            : _shoppingListView(itemCount, snapshot);
          
          buttonToReturn = itemCount == 0
            ? null
            : _compareButton(context);
        }
        else {
          bodyToReturn = CenteredLoadingCircle(
            height: Measure.screenHeightFraction(context, .2),
            width: Measure.screenWidthFraction(context, .4),
          );
        }

        return _ScaffoldTemplate(
          body: bodyToReturn, 
          button: buttonToReturn,
        );
      },
    );
  }

  Widget _shoppingListView(int itemCount, AsyncSnapshot<QuerySnapshot> snapshot) {

    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        DocumentSnapshot document = snapshot.data.docs[index];
        Map<String, dynamic> data = document.data();
        ListItem item = ListItem(
          listItemId: document.id, 
          itemId: data['itemId'],
          barcode: data['barcode'],
          name: data['name'],
          pictureUrl: data['image'],
          quantity: data['quantity']
        );

        return _ListItemCard(item: item,);
      },
    );
  }

  Widget _compareButton(BuildContext context) {

    return ElevatedButton(
      child: Text('Compare'),
      onPressed: () {
        Navigator.push(context, 
          MaterialPageRoute(
            builder: (context) => Compare()
          )
        );
      },
    );
  }
}

class _ScaffoldTemplate extends StatelessWidget {

  static const String title = 'Shopping List';

  final Widget body;
  final Widget button;

  _ScaffoldTemplate({Key key, this.body, this.button}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
          icon: Icon(Icons.home),
          iconSize: 32,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        ],
      ),
      body: body,
      persistentFooterButtons: [button], 
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Text('Your cart is empty.  Add some items to do a comparison.'),
      ),
    );
  }
}

class _ListItemCard extends StatelessWidget {

  static const String itemRemovalErrorMessage = 'Error removing item from cart.';
  final ListItem item;

  _ListItemCard({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<TheUser>(context);
    DatabaseService db = DatabaseService(uid: user.uid);

    // https://api.flutter.dev/flutter/material/ListTile-class.html
    return Card(
      child: ListTile(
        isThreeLine: true,
        leading: Container(
          width: Measure.screenWidthFraction(context, .2),
          height: Measure.screenHeightFraction(context, .2),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(
                item.pictureUrl
              ),
            ),
          ),
        ),
        //Image.network(widget.item.pictureUrl),
        title: Text(
          '${item.name}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: _ListItemDropDownButton(
          item: item,
        ),   
        trailing: RaisedButton(
          child: Text('Remove'),
          onPressed: () async {
            try {
              await db.removeShoppingListItem(item.listItemId);
            }
            catch (error){
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(itemRemovalErrorMessage)
                )
              );
            }
          }
        )
      ),
    );
  }
}

class _ListItemDropDownButton extends StatefulWidget {

  final ListItem item;

  _ListItemDropDownButton({Key key, this.item}) : super(key: key);

  @override
  _ListItemDropDownButtonState createState() => _ListItemDropDownButtonState();
}

class _ListItemDropDownButtonState extends State<_ListItemDropDownButton> {

  final String quantityErrorMessage = 'Error changing the quantity.';

  bool quantityError = false;

  int quantity;

  @override
  void initState() {
    quantity = widget.item.quantity;

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<TheUser>(context);
    DatabaseService db = DatabaseService(uid: user.uid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<int>(
          underline: Container(
            height: 2,
            color: Colors.blueGrey,
          ),
          hint: Text('quantity'),
          value: quantity,
          items: <int>[1, 2, 3, 4, 5, 6, 7].map<DropdownMenuItem<int>>((quantity) {
            return DropdownMenuItem<int>(
              child: Text(quantity.toString()),
              value: quantity,
            );
          }).toList(),
          onChanged: (int newQuantity) async {
            // Avoid wasting a query when they select the same quantity.
            // Also prevent an unnecessary change to the state.
            if (newQuantity != quantity) {
              try {
                await db.updateShoppingListItemQuantity(
                  listItemId: widget.item.listItemId,
                  quantity: newQuantity
                );
                quantity = newQuantity;
              }
              catch (error){
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(quantityErrorMessage)
                  )
                );
              }
              setState(() {});
            }  
          },
        ),
      ],
    );
  }
}