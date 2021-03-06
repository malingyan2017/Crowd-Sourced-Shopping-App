import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_app/Components/centered_loading_circle.dart';
import 'package:shopping_app/Components/store_total_card.dart';
import 'package:shopping_app/Database/database.dart';
import 'package:shopping_app/Models/shopping_list.dart';
import 'package:shopping_app/Models/store.dart';
import 'package:shopping_app/Models/the_user.dart';
import 'package:shopping_app/Util/store_comparison_helper.dart';
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
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.home),
        //     iconSize: 32,
        //     onPressed: () {
        //       Navigator.pop(context);
        //       Navigator.pop(context);
        //     },
        //   ),
        // ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getDatabaseInfo(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          else if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {

            return _CompareBody(
              user: db.createUserFromSnapshot(snapshot),
              shoppingList: shoppingList,
            );
          }
          else {
            return CenteredLoadingCircle();
          }
        },
      ),
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
          return CenteredLoadingCircle();
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
          return CenteredLoadingCircle();
        }
      },
    );
  }

  List<_SortingStruct> createSortedList(List<Store> filledStores) {

    List<_SortingStruct> sortedList = [];

    filledStores.forEach((element) { 

      sortedList.add(_SortingStruct(
        store: element,
        total: getTotalPrice(element.items, widget.shoppingList),
        stalenessStruct: getStoreStalenessInfo(element)
      ));
    });

    sortedList.sort(
      (a, b){

        int result = a.total.compareTo(b.total);

        // Zero would mean the items had the same total price.
        return result == 0
        ? a.stalenessStruct.staleItemCount.compareTo(b.stalenessStruct.staleItemCount)
        : result;
      }
    );

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

    return StoreTotalCard(
      store: store,
      total: total,
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
    );
  }
}

class _SortingStruct {

  Store store;
  double total;
  StalenessStruct stalenessStruct;

  _SortingStruct({this.store, this.total, this.stalenessStruct});
}