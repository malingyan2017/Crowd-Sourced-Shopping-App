import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_app/Components/centered_loading_circle.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/list_item.dart';
import 'package:shopping_app/Models/shopping_list.dart';
import 'package:shopping_app/Models/store.dart';
import 'package:shopping_app/Models/store_item.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'package:shopping_app/Util/measure.dart';


class Compare extends StatefulWidget {
  
  @override
  _CompareState createState() => _CompareState();
}

class _CompareState extends State<Compare> {

  final FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseService db;
  ShoppingList shoppingList;

  @override
  void initState() {

    db = DatabaseService(uid: auth.currentUser.uid);
    super.initState();
  }
  
  Future<DocumentSnapshot> getDatabaseInfo() async {

    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);

    // Get shopping list
    shoppingList = await db.getCurrentShoppingList();

    return db.getUserSnapshot();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Comparison Results'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            iconSize: 32,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getDatabaseInfo(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          else if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {

            return _CompareBody(
              user: createUserFromSnapshot(snapshot),
              shoppingList: shoppingList,
            );
          }
          else {
            return CenteredLoadingCircle(
              height: Measure.screenHeightFraction(context, .2),
              width: Measure.screenWidthFraction(context, .4),
            );
          }
        },
      ),
    );
  }

  TheUser createUserFromSnapshot(AsyncSnapshot<DocumentSnapshot> snapshot) {

    Map<String, dynamic> data = snapshot.data.data();

    return TheUser(
      uid: snapshot.data.id,
      username: data['username'],
      rankPoints: data['rankPoints'],
      preferredStore: Store(
        id: data['preferredLocation']['id'],
        name: data['preferredLocation']['name'],
        streetAddress: data['preferredLocation']['streetAddress'],
        city: data['preferredLocation']['city'],
        state: data['preferredLocation']['state'],
        zipCode: data['preferredLocation']['zipCode']
      )
    );
  }
}

class _CompareBody extends StatefulWidget {

  final TheUser user;
  final ShoppingList shoppingList;

  _CompareBody({Key key, this.user, this.shoppingList}) : super(key: key);

  @override
  _CompareBodyState createState() => _CompareBodyState();
}

class _CompareBodyState extends State<_CompareBody> {

  List<String> barcodes;
  
  @override
  Widget build(BuildContext context) {

    DatabaseService db = DatabaseService(uid: widget.user.uid);

    barcodes = widget.shoppingList.barcodeList();

    // We need to collect the stores first
    return StreamBuilder<QuerySnapshot>(
      stream: db.getStoresStreamFromZipCode(widget.user.preferredStore.zipCode),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        else if (snapshot.hasData) {
          return createBody(context, snapshot, db);
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

  Widget createBody(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot, DatabaseService db) {

    // Our current snapshot is a list of store documents
    List<Store> matchingStores = db.queryToStoreList(snapshot.data.docs);

    return ListView.builder(
      itemCount: matchingStores.length,
      itemBuilder: (BuildContext context, int index) {
        DocumentSnapshot document = snapshot.data.docs[index];
        Map<String, dynamic> data = document.data();
        data['id'] = document.id;
        Store store = Store.storeFromMap(data);

        return _StoreTile(store: store, barcodes: barcodes);
      },
    );

  }
}

class _StoreTile extends StatefulWidget {

  final Store store;
  final List<String> barcodes;

  _StoreTile({Key key, this.store, this.barcodes}) : super(key: key);

  @override
  __StoreTileState createState() => __StoreTileState();
}

class __StoreTileState extends State<_StoreTile> {

  double total = 0;

  // We pass this functions to the store tile children
  void addToTotal(double amountToAdd) {

    setState(() {
      total += amountToAdd;
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> storeItems = getStoreItems();

    return ExpansionTile(
      title: Text('${widget.store.name} - ${widget.store.streetAddress}'),
      subtitle: Text('Total Price $total'),
      //trailing: Text('Total Price $total'),
      children: storeItems,
    );
  }

  List<Widget> getStoreItems() {

    List<Widget> list;

    widget.store.items.forEach((element) { 
      list.add(_StoreItemTile());
    });

    return [Text('Item1'), Text('Item2')];
  }
}

class _StoreItemTile extends StatefulWidget {
  // https://medium.com/@manojvirat457/access-child-widgets-data-in-parent-32e7390e8369
  final StoreItem storeItem;
  final Function(double) addToTotal;

  _StoreItemTile({Key key, this.storeItem, this.addToTotal}) : super(key: key);

  @override
  _StoreItemTileState createState() => _StoreItemTileState();
}

class _StoreItemTileState extends State<_StoreItemTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}




// ListView.builder(
//       itemCount: matchingStores.length,
//       itemBuilder: (BuildContext context, int index) {
//         DocumentSnapshot document = snapshot.data.docs[index];
//         Map<String, dynamic> data = document.data();
//         ListItem item = ListItem(
//           listItemId: document.id, 
//           itemId: data['itemId'],
//           barcode: data['barcode'],
//           name: data['name'],
//           pictureUrl: data['image'],
//           quantity: data['quantity']
//         );

//         return _ListItemCard(item: item,);
//       },
//     );