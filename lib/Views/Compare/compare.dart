import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shopping_app/Components/centered_loading_circle.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/list_item.dart';
import 'package:shopping_app/Models/shopping_list.dart';
import 'package:shopping_app/Models/store.dart';
import 'package:shopping_app/Models/store_item.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'package:shopping_app/Style/custom_text_style.dart';
import 'package:shopping_app/Util/measure.dart';
import 'package:shopping_app/Views/Compare/comparison_details.dart';


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

    return db.getCurrentUserSnapshot();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Store Recommendations'),
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
              user: _createUserFromSnapshot(snapshot),
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

  TheUser _createUserFromSnapshot(AsyncSnapshot<DocumentSnapshot> snapshot) {

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
  
  @override
  Widget build(BuildContext context) {

    DatabaseService db = DatabaseService(uid: widget.user.uid);

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

        return _StoreTile(store: store, shoppingList: widget.shoppingList);
      },
    );

  }
}

class _StoreTile extends StatefulWidget {

  final Store store;
  final ShoppingList shoppingList;

  _StoreTile({Key key, this.store, this.shoppingList}) : super(key: key);

  @override
  _StoreTileState createState() => _StoreTileState();
}

class _StoreTileState extends State<_StoreTile> {

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {

    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);

    List<String> barcodes = widget.shoppingList.barcodeList();

    Stream<QuerySnapshot> storeItemStream = 
      db.getStoreItemsStreamFromBarcodes(widget.store.id, barcodes);

    return StreamBuilder<QuerySnapshot>(
      stream: storeItemStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        else if (snapshot.hasData) {

          widget.store.items = db.queryToStoreItemList(snapshot.data.docs);

          _addStoreItemQuantity(widget.store, widget.shoppingList);

          double total = _getTotalPrice(widget.store.items);
          // https://stackoverflow.com/questions/54152176/listview-inside-expansiontile-doesnt-work
          // List<Widget> storeItemTiles = _getStoreItemTiles(widget.store.items);

          // https://stackoverflow.com/questions/39958472/dart-numberformat
          // return ExpansionTile(
          //   title: Text('${widget.store.name} - ${widget.store.streetAddress}'),
          //   subtitle: Text('Total Price ${total.toStringAsFixed(2)}'),
          //   //trailing: Text('Total Price $total'),
          //   children: [
          //     ListView.builder(
          //       shrinkWrap: true,
          //       physics: NeverScrollableScrollPhysics(),
          //       scrollDirection: Axis.vertical,
          //       itemCount: storeItemTiles.length,
          //       itemBuilder: (BuildContext context, int index) {

          //         return storeItemTiles[index];
          //       }
          //     )
          //   ],
          // );

          return ListTile(
            title: Text('${widget.store.name} - ${widget.store.streetAddress}'),
            subtitle: Text('Total Price ${total.toStringAsFixed(2)}'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () { 
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComparisonDetails(
                    store: widget.store,
                    barcodes: barcodes,
                    //storeItemsStream: storeItemStream,
                  )
                ),
              );
            },
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

  // List<Widget> _getStoreItemTiles(List<StoreItem> storeItemsList) {

  //   List<Widget> list = [];

  //   storeItemsList.forEach((StoreItem storeItem) { 
  //     list.add(_StoreItemTile(
  //       storeItem: storeItem,
  //       store: widget.store,
  //     ));
  //   });

  //   return list;
  // }

  double _getTotalPrice(List<StoreItem> storeItems) {

    double total = 0;

    storeItems.forEach((StoreItem storeItem) {
      total += storeItem.price * storeItem.quantity;
    });

    return total;
  }

  void _addStoreItemQuantity(Store store, ShoppingList shoppingList) {

    store.items.forEach((StoreItem storeItem) { 

      ListItem listItem = 
        shoppingList.items.firstWhere((element) => element.barcode == storeItem.barcode);
      
      storeItem.quantity = listItem.quantity;
    });
  }

}

// class _StoreItemTile extends StatefulWidget {

//   final StoreItem storeItem;
//   final Store store;

//   _StoreItemTile({Key key, this.storeItem, this.store}) : super(key: key);

//   @override
//   _StoreItemTileState createState() => _StoreItemTileState();
// }

// // The structure is taken from the livefeed_price_updates file that Jasmine wrote.
// class _StoreItemTileState extends State<_StoreItemTile> {

//   final FirebaseAuth auth = FirebaseAuth.instance;

//   // Text Widget to Bold Item Text
//   Text itemInfoText(String text) {
//     return Text(
//       text,
//       style: CustomTextStyle.itemInfo
//     );
//   }

//   // Text Widget for Price Styling
//   Text itemPriceText(String text) {
//     return Text(
//       text,
//       style: CustomTextStyle.itemPrice
//     );
//   }

//   Widget build(BuildContext context) {
 
//     DatabaseService db = DatabaseService(uid: auth.currentUser.uid);

//     Widget userInfo(Map<String, dynamic> userData) {

//       // Calculate User's rank and retrieve icon
//       int userPoints = userData['rankPoints'];
//       Icon icon = db.getRankIcon(userPoints);
//       String user = 'Updated by: ' + userData['username'] + ' ';

//       return Row(
//         children: <Widget>[
//           Text(user), icon, 
//         ],
//       );
//     }

//     Widget locationInfo() {

//       String message = widget.store.name + ' in ' + widget.store.cityStateZip;
      
//       return Text(message);
//     }

//     return StreamBuilder<DocumentSnapshot>(
//       stream: db.getUserStream(auth.currentUser.uid),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Text("Something went wrong");
//         } else if (snapshot.hasData) {

//           // Get formatted time stamp of when price update was posted
//           // Timestamp timestamp = data['dateUpdated'] ;
//           // DateTime myDateTime =
//           //     DateTime.parse(timestamp.toDate().toString());
//           String formattedDateTime =
//               DateFormat('MM-dd-yyyy').format(widget.storeItem.lastUpdate);

//           // Variables to Hold Store Item Info
//           var itemName = widget.storeItem.name;
//           var itemPrice = '\$' + widget.storeItem.price.toString();
//           var onSale = widget.storeItem.onSale;

//           return SizedBox(
//             height: 90,
//             child: Card(
//               child: Stack(
//                 children: <Widget>[
//                   Row(
//                     children: <Widget>[
//                       Container(
//                         width: 60,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           image: DecorationImage(
//                             image: NetworkImage(widget.storeItem.pictureUrl),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(left: 8.0, bottom: 25.0),
//                         child: itemInfoText(itemName),
//                       ),
//                     ],
//                   ),
//                   Positioned(
//                     top: 10,
//                     right: 3,
//                     child: Stack(
//                       children: <Widget>[
//                         Text('$formattedDateTime'),
//                       ],
//                     ),
//                   ),
//                   Positioned(
//                     top: 30,
//                     left: 70,
//                     child: itemPriceText(itemPrice),
//                   ),
//                   Positioned(
//                     left: 45,
//                     top: 46,
//                     child: Checkbox(
//                       checkColor: Colors.black,
//                       onChanged: null,
//                       value: onSale,
//                     ),
//                   ),
//                   Positioned(
//                     left: 0.2,
//                     bottom: 3,
//                     child: Text('On Sale?'),
//                   ),
//                   Positioned(
//                     top: 43,
//                     right: 3,
//                     child: userInfo(snapshot.data.data()),
//                   ),
//                   Positioned(
//                     bottom: 1,
//                     right: 3,
//                     child: locationInfo(),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//         return Center(child: CircularProgressIndicator());
//       },
//     );
//   }
// }
