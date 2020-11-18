import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shopping_app/Components/centered_loading_circle.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/store.dart';
import 'package:shopping_app/Models/store_item.dart';
import 'package:shopping_app/Style/custom_text_style.dart';
import 'package:shopping_app/Util/measure.dart';

// This could potentially be done using all of the information collected by
// the comparison page.  I believe the objective is for the information to update
// along with any changes to an item's price.
class ComparisonDetails extends StatelessWidget {
  final Store store;
  final List<String> barcodes;
  //final Stream<QuerySnapshot> storeItemsStream;

  ComparisonDetails({Key key, this.store, this.barcodes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('View Details'),
      ),
      body: _DetailBody(
        store: store,
        barcodes: barcodes,
      ),
    );
  }
}

class _DetailBody extends StatefulWidget {
  final Store store;
  final List<String> barcodes;
  //final Stream<QuerySnapshot> storeItemsStream;

  _DetailBody({Key key, this.store, this.barcodes}) : super(key: key);

  @override
  _DetailBodyState createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    DatabaseService db = DatabaseService(uid: auth.currentUser.uid);

    return StreamBuilder<QuerySnapshot>(
      stream:
          db.getStoreItemsStreamFromBarcodes(widget.store.id, widget.barcodes),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        } else if (snapshot.hasData) {
          List<StoreItem> newStoreItems =
              db.queryToStoreItemList(snapshot.data.docs);

          _addStoreItemQuantity(widget.store, newStoreItems);

          double total = _getTotalPrice(newStoreItems);

          // https://stackoverflow.com/questions/54152176/listview-inside-expansiontile-doesnt-work
          List<Widget> storeItemTiles = _getStoreItemTiles(newStoreItems);

          // https://stackoverflow.com/questions/39958472/dart-numberformat
          // https://stackoverflow.com/questions/52801201/flutter-renderbox-was-not-laid-out
          return Container(
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    title: Text(
                        '${widget.store.name} - ${widget.store.streetAddress}'),
                    subtitle: Text('Total Price ${total.toStringAsFixed(2)}'),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      //shrinkWrap: true,
                      //physics: NeverScrollableScrollPhysics(),
                      //scrollDirection: Axis.vertical,
                      itemCount: storeItemTiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        return storeItemTiles[index];
                      }),
                )
              ],
            ),
          );
        } else {
          return CenteredLoadingCircle(
            height: Measure.screenHeightFraction(context, .2),
            width: Measure.screenWidthFraction(context, .4),
          );
        }
      },
    );
  }

  void _addStoreItemQuantity(Store store, List<StoreItem> newStoreItems) {
    newStoreItems.forEach((StoreItem newItem) {
      StoreItem original = store.items.firstWhere((StoreItem currentItem) {
        return currentItem.barcode == newItem.barcode;
      }, orElse: () => null);

      newItem?.quantity = original?.quantity;
    });
  }

  double _getTotalPrice(List<StoreItem> storeItems) {
    double total = 0;

    storeItems.forEach((StoreItem storeItem) {
      total += storeItem.price * storeItem.quantity;
    });

    return total;
  }

  List<Widget> _getStoreItemTiles(List<StoreItem> storeItemsList) {
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

    Widget locationInfo() {
      String message = widget.store.name + ' in ' + widget.store.cityStateZip;

      return Text(message);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: db.getUserStream(auth.currentUser.uid),
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

          // Variables to Hold Store Item Info
          var itemName = widget.storeItem.name;
          var itemPrice = '\$' + widget.storeItem.price.toString();
          var onSale = widget.storeItem.onSale;

          return SizedBox(
            height: 90,
            child: Card(
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
                    top: 43,
                    right: 3,
                    child: userInfo(snapshot.data.data()),
                  ),
                  Positioned(
                    bottom: 1,
                    right: 3,
                    child: locationInfo(),
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
