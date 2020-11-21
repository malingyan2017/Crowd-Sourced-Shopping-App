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
import 'package:shopping_app/Util/helper.dart';
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

          return createBody(context, db.queryToStoreList(snapshot.data.docs), db);
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

  Widget createBody(BuildContext context, List<Store> matchingStores, DatabaseService db) {

    return StreamBuilder(
      stream: db.getStoresWithStoreItems(matchingStores, widget.shoppingList.barcodeList()),
      builder: (BuildContext context, snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        else if (snapshot.hasData) {

          List<Store> filledMatchingStores = snapshot.data;

          List<_SortingStruct> sortedList = createSortedList(filledMatchingStores);

          return ListView.builder(   
            itemCount: sortedList.length,
            itemBuilder: (BuildContext context, int index) {
              return _StoreTile(
                store: sortedList[index].store, 
                total: sortedList[index].total,
                shoppingList: widget.shoppingList,
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

  List<_SortingStruct> createSortedList(List<Store> filledStores) {

    List<_SortingStruct> sortedList = [];

    filledStores.forEach((element) { 

      sortedList.add(_SortingStruct(
        store: element,
        total: getTotalPrice(element.items, widget.shoppingList)
      ));
    });

    sortedList.sort((a, b) => a.total.compareTo(b.total));

    return sortedList;
  }
}

class _StoreTile extends StatelessWidget {

  final FirebaseAuth auth = FirebaseAuth.instance;

  final Store store;
  final ShoppingList shoppingList;
  final double total;

  _StoreTile({Key key, this.store, this.shoppingList, this.total}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Card(
      child: ListTile(
        title: Text('${store.name} - ${store.streetAddress}'),
        subtitle: Text('Total Price \$${total.toStringAsFixed(2)}'),
        trailing: Icon(Icons.arrow_forward),
        onTap: () { 
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComparisonDetails(
                store: store,
                shoppingList: shoppingList,
              )
            ),
          );
        },
      ),
    );
  }

}

class _SortingStruct {

  Store store;
  double total;

  _SortingStruct({this.store, this.total});
}