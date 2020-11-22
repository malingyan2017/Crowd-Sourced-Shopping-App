import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shopping_app/Components/centered_loading_circle.dart';
import 'package:shopping_app/Components/store_total_card.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/shopping_list.dart';
import 'package:shopping_app/Models/store.dart';
import 'package:shopping_app/Models/store_item.dart';
import 'package:shopping_app/Style/custom_text_style.dart';
import 'package:shopping_app/Util/measure.dart';
import 'package:shopping_app/Util/store_comparison_helper.dart';

// This could potentially be done using all of the information collected by
// the comparison page.  I believe the objective is for the information to update
// along with any changes to an item's price.
class ComparisonDetails extends StatelessWidget {
  final Store store;
  final ShoppingList shoppingList;

  ComparisonDetails({Key key, this.store, this.shoppingList}) : super(key: key);

  // https://api.flutter.dev/flutter/material/showModalBottomSheet.html
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('View Details'),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.info),
        //     iconSize: 32,
        //     onPressed: () {
        //       showModalBottomSheet(
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.all(Radius.circular(10))
        //         ),
        //         context: context, 
        //         builder: (context) {
        //           return bottomSheet(context);
        //         }
        //       );
        //     },
        //   ),
        // ],
      ),
      body: _DetailBody(
        store: store,
        shoppingList: shoppingList,
      ),
    );
  }

  // Widget bottomSheet(BuildContext context) {
  //   return Center(
  //     heightFactor: Measure.screenHeightFraction(context, 0.2),
  //     child: Text(
  //       'All marked items were last updated three weeks or more from today and may no longer represent the actual price of the item listed.',
  //       style: Theme.of(context).textTheme.bodyText1,
  //     ),
  //   );
  // }
}

class _DetailBody extends StatefulWidget {
  final Store store;
  final ShoppingList shoppingList;

  _DetailBody({Key key, this.store, this.shoppingList}) : super(key: key);

  @override
  _DetailBodyState createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);

    return StreamBuilder(
      stream:
          db.getStoreItemsListStreamFromBarcodes(widget.store.id, widget.shoppingList.barcodeList()),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        } else if (snapshot.hasData) {
          List<StoreItem> newStoreItems = snapshot.data;
              //db.queryToStoreItemList(snapshot.data.docs);

          double total = getTotalPrice(newStoreItems, widget.shoppingList);

          // https://stackoverflow.com/questions/54152176/listview-inside-expansiontile-doesnt-work
          List<Widget> storeItemTiles = _getStoreItemTiles(newStoreItems);

          // https://stackoverflow.com/questions/39958472/dart-numberformat
          // https://stackoverflow.com/questions/52801201/flutter-renderbox-was-not-laid-out
          return Container(
            child: Column(
              children: [
                StoreTotalCard(
                  store: widget.store,
                  total: total,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: storeItemTiles.length,
                    itemBuilder: (BuildContext context, int index) {

                      return storeItemTiles[index];
                    }
                  ),
                )
              ],
            ),
          );
        } else {
          return CenteredLoadingCircle();
        }
      },
    );
  }

  List<Widget> _getStoreItemTiles(List<StoreItem> storeItemsList) {

    // Sorting will give the list of items a consistent appearance.
    storeItemsList.sort(
      (a,b) => a.name.toLowerCase().trim().compareTo(b.name.toLowerCase().trim())
    );

    List<Widget> list = [];

    storeItemsList.forEach((StoreItem storeItem) {
      list.add(_StoreItemTile(
        storeItem: storeItem,
        store: widget.store,
      ));
    });

    return list;
  }
}

class _StoreItemTile extends StatefulWidget {
  final StoreItem storeItem;
  final Store store;

  _StoreItemTile({Key key, this.storeItem, this.store}) : super(key: key);

  @override
  _StoreItemTileState createState() => _StoreItemTileState();
}

// The structure is taken from the livefeed_price_updates file that Jasmine wrote.
class _StoreItemTileState extends State<_StoreItemTile> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Text Widget to Bold Item Text
  Text itemInfoText(String text) {
    return Text(text, style: CustomTextStyle.itemInfo);
  }

  // Text Widget for Price Styling
  Text itemPriceText(String text) {
    return Text(text, style: CustomTextStyle.itemPrice);
  }

  Widget build(BuildContext context) {
    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);

    Widget userInfo(Map<String, dynamic> userData) {
      // Calculate User's rank and retrieve icon
      int userPoints = userData['rankPoints'];
      Icon icon = db.getRankIcon(userPoints);
      String user = 'Updated by: ' + userData['username'] + ' ';

      return Row(
        children: <Widget>[
          Text(user),
          icon,
        ],
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: db.getUserStream(widget.storeItem.lastUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        } else if (snapshot.hasData) {
          // Get formatted time stamp of when price update was posted
          // Timestamp timestamp = data['dateUpdated'] ;
          // DateTime myDateTime =
          //     DateTime.parse(timestamp.toDate().toString());
          String formattedDateTime =
              DateFormat('MM-dd-yyyy').format(widget.storeItem.lastUpdate);

          //double totalPrice = widget.storeItem.price * widget.storeItem.quantity;
          // Variables to Hold Store Item Info
          var itemName = widget.storeItem.name;
          var itemPrice = '\$' + (widget.storeItem.price).toStringAsFixed(2) + ' [${widget.storeItem.quantity}]';
          var onSale = widget.storeItem.onSale;

          ShapeBorder shape = isStale(widget.storeItem) 
          ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0), 
            side: BorderSide(
              color: Colors.red,
              width: 2
            )
          )
          : null;

          // // https://stackoverflow.com/questions/50783354/how-to-highlight-the-border-of-a-card-selected
          return SizedBox(
            height: 90,
            child: Card(
              shape: shape,
              child: Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 60,
                        height: 60,
                        child: CachedNetworkImage(
                          imageUrl: widget.storeItem.pictureUrl,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0, bottom: 25.0),
                        child: itemInfoText(itemName),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 3,
                    child: Stack(
                      children: <Widget>[
                        Text('$formattedDateTime'),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 30,
                    left: 70,
                    child: itemPriceText(itemPrice),
                  ),
                  Positioned(
                    left: 45,
                    top: 46,
                    child: Checkbox(
                      checkColor: Colors.black,
                      onChanged: null,
                      value: onSale,
                    ),
                  ),
                  Positioned(
                    left: 0.2,
                    bottom: 3,
                    child: Text('On Sale?'),
                  ),
                  Positioned(
                    bottom: 1,
                    right: 3,
                    child: userInfo(snapshot.data.data()),
                  ),
                ],
              ),
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
