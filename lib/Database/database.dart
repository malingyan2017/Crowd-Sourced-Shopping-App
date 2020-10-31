import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shopping_app/Constants/database_constants.dart';

import 'package:shopping_app/Models/review.dart';
import 'package:shopping_app/Models/store.dart';
import 'package:shopping_app/Models/store_item.dart';


class DatabaseService {
  final String uid;

  DatabaseService({this.uid});

  final fireStore = FirebaseFirestore.instance;

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection(DatabaseConstants.users);

  final CollectionReference storeCollection =
      FirebaseFirestore.instance.collection(DatabaseConstants.stores);

  final CollectionReference itemCollection =
      FirebaseFirestore.instance.collection(DatabaseConstants.items);

  //add to cart function
  Future addToCart(
      String itemId, String name, String image, int quantity) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('shoppingList')
        .doc()
        .set({
      'name': name,
      'image': image,
      'itemId': itemId,
      'quantity': quantity
    });
  }

  //create if not there or update the user data in data base
  Future updateUsers(String username, int rank, String location) async {
    return await userCollection.doc(uid).set({
      'username': username,
      'rankPoints': rank,
      'location': location,
    });
  }

  Future<bool> usernameExists(String username) async {
    QuerySnapshot querySnapshot =
        await userCollection.where('username', isEqualTo: username).get();

    return querySnapshot.size >= 1;
  }

  Future<void> updateUsername(String username) async {
    userCollection.doc(uid).update({'username': username});
  }

  Future<void> updateUserPreferredLocation(Store newStore) async {
    userCollection.doc(uid).update({
      'preferredLocation.id': newStore.id,
      'preferredLocation.name': newStore.name,
      'preferredLocation.streetAddress': newStore.streetAddress,
      'preferredLocation.city': newStore.city,
      'preferredLocation.state': newStore.state,
      'preferredLocation.zipCode': newStore.zipCode
      }
    );
  }

  String pointsToRank(int points) {
    List<String> rankings = [];

    return null;
  }

  Future<DocumentSnapshot> getUserSnapshot() {
    return userCollection.doc(uid).get();
  }

  Stream<DocumentSnapshot> getUserStream() {
    return userCollection.doc(uid).snapshots();
  }

  Future<DocumentSnapshot> getStoreSnapshot(String storeId) {
    return storeCollection.doc(storeId).get();
  }

  // Searches for items matching the keywords passed in.
  // Returns a Future list of QuerySnapshots.
  // The first item in the list represents all items that match by name.
  // The second item in the list represents all items that contain a matching tag.
  // Will throw an error if something goes wrong with the query.
  Future<List<QuerySnapshot>> searchForItemByKeywords(String keywords) async {
    List<QuerySnapshot> snapshots = [];

    snapshots.add(await searchForItemByName(keywords));
    snapshots.add(await searchForItemByTag(keywords));

    return snapshots;
  }

  // Searches for any items with a matching name.
  // Returns the Future QuerySnapshot.
  // https://firebase.flutter.dev/docs/firestore/usage/#querying
  // https://firebase.googleblog.com/2018/08/better-arrays-in-cloud-firestore.html
  Future<QuerySnapshot> searchForItemByName(String name) async {
    return itemCollection.where('name', isEqualTo: name).get();
  }

  // Searches for any items with a matching tag.
  // Returns the Future QuerySnapshot.
  // https://firebase.flutter.dev/docs/firestore/usage/#filtering
  Future<QuerySnapshot> searchForItemByTag(String tag) async {
    return itemCollection.where('tags', arrayContains: tag).get();
  }

  /*
  // Updates a store item's price based on the information passed in.
  // Provides a user points for updating the price. 
  // Error checking should be done to avoid calling this method if no 
  // information is changed by the user.
  // Will throw an exception if the update fails.
  // Will do nothing if the price is <= 0.
  // https://firebase.flutter.dev/docs/firestore/usage/#updating-documents
  Future<void> updateItemPrice (
    {@required StoreItem storeItem, @required String storeId, @required double price}) async {

    if (price <= 0) {

      return;
    }

    // GRAB USER

    fireStore
    .collection(DatabaseConstants.stores)
    .doc(storeId)
    .collection(DatabaseConstants.storeItems)
    .doc(storeItem.storeItemId)
    .update(
      {
        'price': price
      }
    );

    updateUserScore(DatabaseConstants.pointsForUpdatingPrice);
  } 
  */

  // Adds tagToAdd to the tags associated with the passed in item.
  // Provides a user points for updating the tags.
  // Will throw an exception if the update fails.
  // Will do nothing if the tagToAdd string is empty or null
  Future<void> updateItemTags(
      {@required StoreItem storeItem, @required String tagToAdd}) async {
    if (tagToAdd == null || tagToAdd == '') {
      return;
    }

    itemCollection.doc(storeItem.itemId).update({
      // The arrayUnion method will do nothing if the elements already exist
      // in the array
      // https://firebase.googleblog.com/2018/08/better-arrays-in-cloud-firestore.html
      'tags': FieldValue.arrayUnion([tagToAdd])
    });

    //updateUserScore(DatabaseConstants.pointsForUpdatingTags);
  }

  // Increments the user's score by the indicated amount.
  // Throws an exception if the update fails.
  Future<void> updateUserScore(int pointsToAdd) async {
    userCollection
        .doc(uid)
        .update({'points': FieldValue.increment(pointsToAdd)});
  }

  // Add review for a given store.
  // Throws an exception if the add fails.
  Future<void> addStoreReview(String storeId, Review review) async {

    storeCollection
    .doc(storeId)
    .collection('reviews')
    .add(
      {
        'userId': uid,
        'rating': review.rating,
        'dateWritten': review.dateCreated,
        'body': review.body
      }
    );

    // TO DO: Provide points to the user for providing a rating.
  }

  // Returns the most recent reviews written throughout the database
  // as a stream.
  Stream<QuerySnapshot> getRecentReviews(int limit) {
    return fireStore
        .collectionGroup(DatabaseConstants.reviews)
        .orderBy('dateCreated', descending: true)
        .limit(limit)
        .snapshots();
  }

  // Returns the most recent price updates written throughout the database
  // as a stream.
  Stream<QuerySnapshot> getRecentPriceUpdates(int limit) {
    return fireStore
        .collectionGroup(DatabaseConstants.storeItems)
        .orderBy('lastUpdate', descending: true)
        .limit(limit)
        .snapshots();
  }

  // Returns the user's shopping list as a stream.
  Stream<QuerySnapshot> getShoppingList() {
    return userCollection
        .doc(uid)
        .collection(DatabaseConstants.shoppingList)
        .snapshots();
  }

  Future<void> removeShoppingListItem() {

    
  }

  // Get all stores as a query snapshot.
  Future<QuerySnapshot> getStoreListQuery() {

    return storeCollection.get();
  }

  // Converts a list of maps into a list of store objects.  
  List<Store> queryToStoreList(List<QueryDocumentSnapshot> storeList) {

    return storeList.map((QueryDocumentSnapshot snapshot) {
      Map<String, dynamic> store = snapshot.data();

      return Store(
        id: snapshot.id,
        name: store['name'],
        streetAddress: store['streetAddress'],
        city: store['city'],
        state: store['state'],
        zipCode: store['zipCode']
      );
    }).toList();
  }

  /*// Creates a set of store items inside of every store.
  void initializeAllStoreItems() async {

    DocumentSnapshot userSnapshot = await userCollection.doc(uid).get();
    QuerySnapshot itemSnapshot = await itemCollection.get();

    List<StoreItem> items = itemSnapshot.docs.map((QueryDocumentSnapshot snapshot) {
      Map<String, dynamic> item = snapshot.data();

      return StoreItem(
        itemId: snapshot.id,
        barcode: item['barcode'],
        name: item['name'],
        pictureUrl: item['pictureUrl'],
      );
    }).toList();

    QuerySnapshot storeSnapshot = await storeCollection.get();

    List<String> storeIds = [];

    storeSnapshot.docs.toList().forEach((QueryDocumentSnapshot snapshot) { 

      storeIds.add(snapshot.id);
    });

    // Copy every item into every store's storeItem subcollection
    items.forEach((StoreItem item) { 
      storeIds.forEach((String storeId) { 

        storeCollection
        .doc(storeId)
        .collection(DatabaseConstants.storeItems)
        .add({
          'userId': uid,
          'itemId': item.itemId,
          'barcode': item.barcode,
          'name': item.name,
          'pictureUrl': item.pictureUrl,
          'price': 10.99,
          'onSale': false,
          'dateUpdated': DateTime.now()
        });
      });
    });
  }*/
}


