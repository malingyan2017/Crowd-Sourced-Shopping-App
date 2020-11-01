import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/Components/centered_loading_circle.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/item.dart';
import 'package:shopping_app/Models/list_item.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'package:shopping_app/Util/measure.dart';

class ShoppingList extends StatefulWidget {
  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<TheUser>(context);
    DatabaseService db = DatabaseService(uid: user.uid);

    return StreamBuilder<QuerySnapshot>(
      stream: db.getShoppingList(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        else if (snapshot.hasData) {
          //Map<String, dynamic> data = snapshot.data.data();

          return ListView.builder(
            itemCount: snapshot.data.docs.length,
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
            }
          );
        }
        else {
          return CenteredLoadingCircle(
            height: Measure.screenHeightFraction(context, .2),
            width: Measure.screenWidthFraction(context, .4),
          );
        }
      },
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Text('Your cart is empty.  Add some more items to do a comparison.'),
      ),
    );
  }
}

class _ListItemCard extends StatefulWidget {

  final ListItem item;

  _ListItemCard({Key key, this.item}) : super(key: key);

  @override
  _ListItemCardState createState() => _ListItemCardState();
}

class _ListItemCardState extends State<_ListItemCard> {

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
                widget.item.pictureUrl
              ),
            ),
          ),
        ),
        //Image.network(widget.item.pictureUrl),
        title: Text('${widget.item.name}'),
        subtitle: _ListItemDropDownButton(
          item: widget.item,
        ),
        trailing: RaisedButton(
          child: Text('Remove'),
          onPressed: () async {
            await db.removeShoppingListItem(widget.item.itemId);
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
                quantityError = true;
              }
              setState(() {});
            }  
          },
        ),
      ],
    );
  }
}