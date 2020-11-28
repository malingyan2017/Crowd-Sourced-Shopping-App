import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    return StreamBuilder(
      stream: db.getCurrentUserStream(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return _ErrorScaffoldTemplate(body: Text("Something went wrong"),);
          // return _ScaffoldTemplate(body: Text("Something went wrong"));
        } else if (snapshot.hasData) {

          TheUser user = db.createUserFromSnapshot(snapshot);
          return _buildPage(context, user);

        } else {
          return _ErrorScaffoldTemplate(body: CenteredLoadingCircle(),);
        }
      }
    );
  }

  Widget _shoppingListView(int itemCount, List<ListItem> items) {

    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
        return _ListItemCard(
          item: items[index],
        );
      },
    );
  }

  Widget _buildPage(BuildContext context, TheUser user) {

    DatabaseService db = DatabaseService(uid: user.uid);

    return StreamBuilder<QuerySnapshot>(
      stream: db.getShoppingListStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget bodyToReturn;

        if (snapshot.hasError) {
          return _ErrorScaffoldTemplate(body: Text("Something went wrong"));
          
        } else if (snapshot.hasData) {
          //Map<String, dynamic> data = snapshot.data.data();

          itemCount = snapshot.data.docs.length;

          List<ListItem> items = db.queryToListItemList(snapshot.data.docs);

          items.sort(
            (a,b) => a.name.toLowerCase().trim().compareTo(b.name.toLowerCase().trim())
          );

          bodyToReturn = itemCount == 0
            ? _EmptyCart()
            : _shoppingListView(itemCount, items);

          return _ScaffoldTemplate(
            user: user,
            itemCount: itemCount,
            body: bodyToReturn,
          );

        } else {
          return _ErrorScaffoldTemplate(body: CenteredLoadingCircle(),);
        }
      },
    );
  }

  
}

class _ErrorScaffoldTemplate extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  static const String title = 'Shopping List';

  final Widget body;

  _ErrorScaffoldTemplate({Key key, this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: body,
    );
  }
}

class _ScaffoldTemplate extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  static const String title = 'Shopping List';

  final TheUser user;
  final int itemCount;
  final Widget body;

  _ScaffoldTemplate({Key key, this.user, this.itemCount, this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: body,
      persistentFooterButtons: [Builder(
        builder: (BuildContext context) {
          return _compareButton(context, user);
        } 
      )],
    );
  }

  Widget _compareButton(BuildContext context, TheUser user) {

    return ElevatedButton(
      child: Text('Compare'),
      onPressed: itemCount == 0 
      ? null
      : () {
        if (user.preferredStore != null) {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => Compare()
            )
          );
        }
        else {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select a location before attempting to compare.')
            )
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
        child: Text('Your cart is empty.  Add some items to do a comparison.'),
      ),
    );
  }
}

class _ListItemCard extends StatelessWidget {
  static const String itemRemovalErrorMessage =
      'Error removing item from cart.';
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
          child: CachedNetworkImage(
            imageUrl: item.pictureUrl,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
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
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removing ${item.name} from your list.')
                  )
                );
                await db.removeShoppingListItem(item.listItemId);
              } catch (error) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text(itemRemovalErrorMessage)));
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
          items:
              <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map<DropdownMenuItem<int>>((quantity) {
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
                    listItemId: widget.item.listItemId, quantity: newQuantity);
                quantity = newQuantity;
              } catch (error) {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text(quantityErrorMessage)));
              }
              setState(() {});
            }
          },
        ),
      ],
    );
  }
}
