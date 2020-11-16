import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/Constants/database_constants.dart';
import 'package:shopping_app/Models/list_item.dart';
import 'package:shopping_app/Models/review.dart';
import 'package:shopping_app/Models/shopping_list.dart';
import 'package:shopping_app/Models/store.dart';
import 'package:shopping_app/Models/store_item.dart';

// Class to store information to be used across various pages/widgets in the Reviews features
class StoreData {
  String sId;

  StoreData({this.sId});
}

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

  //get rank icon by icon class, call this function directly where you need an icon
  Icon getRankIcon(int points) {
    if (points < 5) {
      return Icon(
        Icons.emoji_events,
        color: Colors.brown,
      );
    } else if (points < 10) {
      return Icon(
        Icons.emoji_events,
        color: Colors.grey,
      );
    } else {
      return Icon(
        Icons.emoji_events,
        color: Colors.amber,
      );
    }
  }

  //get rank icon by url
  String getRankIconUrl(int points) {
    if (points < 5) {
      return 'https://uago.at/-RYyC/sgim.svg';
    } else if (points < 10) {
      return 'https://uago.at/-8R_F/sgim.svg';
    } else {
      return 'https://uago.at/-nq6x/sgim.svg';
    }
  }

  //get user rank by lingyan
  String getUserRank(int points) {
    if (points < 5) {
      return 'Novice';
    } else if (points < 10) {
      return 'JourneyMan';
    } else {
      return 'Master';
    }
  }

  //update user rankPoints by lingyan
  Future<void> updateRankPoints(int points, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'rankPoints': FieldValue.increment(points),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // update storeItem by lingyan
  Future<void> updateItem(String storeId, String itemId, double price,
      bool sale, String uid) async {
    return await FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('storeItems')
        .doc(itemId)
        .update({
      'price': price,
      'onSale': sale,
      'dateUpdated': DateTime.now(),
      'userId': uid,
    });
  }

  //add tags to item by lingyan
  Future<void> addTag(String tag, String itemId) async {
    return await FirebaseFirestore.instance
        .collection('item')
        .doc(itemId)
        .update({
      'tags': FieldValue.arrayUnion([tag]),
    });
  }

  //add to cart function by lingyan
  Future addToCart(String itemId, String name, String image, int quantity,
      String barcode) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('shoppingList')
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();

    if (result.size == 0) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('shoppingList')
          .doc()
          .set({
        'name': name,
        'image': image,
        'itemId': itemId,
        'quantity': quantity,
        'barcode': barcode,
      });
    } else {
      var doc = result.docs[0];
      String id = doc.id;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('shoppingList')
          .doc(id)
          .update({
        'quantity': FieldValue.increment(quantity),
      });
    }
  }

  //gte store info by lingyan
  Future<DocumentSnapshot> gotStoreInfo(String storeId) async {
    var result = await FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .get();

    return result;
  }

  //create if not there or update the user data in data base by lingyan
  Future updateUsers(String username, int rank) async {
    return await userCollection.doc(uid).set({
      'username': username,
      'rankPoints': rank,
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
    });
  }

  String pointsToRank(int points) {
    List<String> rankings = [];

    return null;
  }

  Future<DocumentSnapshot> getCurrentUserSnapshot() {
    return userCollection.doc(uid).get();
  }

  Stream<QuerySnapshot> get items {
    return itemCollection.snapshots();
  }

  Stream<DocumentSnapshot> getCurrentUserStream() {
    return userCollection.doc(uid).snapshots();
  }

  Stream<DocumentSnapshot> getUserStream(String userId) {

    return userCollection.doc(userId).snapshots();
  }

  Stream<DocumentSnapshot> getStoreStream(String storeId) {
    return storeCollection.doc(storeId).snapshots();
  }

  Stream<QuerySnapshot> getItemStream(String barcode) {
    return itemCollection.where('barcode', isEqualTo: barcode).snapshots();
  }

  Stream<QuerySnapshot> getStoreItemStream(String storeId, String barcode) {
    return storeCollection
        .doc(storeId)
        .collection('storeItems')
        .where('barcode', isEqualTo: barcode)
        .snapshots();
  }

  Stream<QuerySnapshot> getStoreReviewsStream(String locationId) {
    return storeCollection
        .doc(locationId)
        .collection('reviews')
        .orderBy('date_created', descending: true)
        .snapshots();
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
    storeCollection.doc(storeId).collection('reviews').add({
      'user_id': uid,
      'rating': review.rating,
      'date_created': review.dateCreated,
      'body': review.body
    });

    // TO DO: Provide points to the user for providing a rating.
  }

  // This will edit and update a store review
  Future<void> updateStoreReview(String storeId, Review review) {
    return storeCollection
        .doc(storeId)
        .collection('reviews')
        .doc(review.id)
        .update({
          'rating': review.rating,
          'date_edited': review.dateEdited,
          'body': review.body
        })
        .then((value) => print("Review Updated"))
        .catchError((error) => print("Failed to update review: $error"));
  }

  // Deletes a review from the database for a given store and review
  Future<void> deleteReview(String storeId, String reviewId) {
    return storeCollection
        .doc(storeId)
        .collection('reviews')
        .doc(reviewId)
        .delete()
        .then((value) => print("Review Deleted"))
        .catchError((error) => print("Failed to delete review: $error"));
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
  Stream<QuerySnapshot> getShoppingListStream() {
    return userCollection
        .doc(uid)
        .collection(DatabaseConstants.shoppingList)
        .snapshots();
  }

  Future<void> removeShoppingListItem(String listItemId) {
    return userCollection
        .doc(uid)
        .collection(DatabaseConstants.shoppingList)
        .doc(listItemId)
        .delete();
  }

  Future<void> updateShoppingListItemQuantity(
      {String listItemId, int quantity}) {
    return FirebaseFirestore.instance
        .collection(DatabaseConstants.users)
        .doc(uid)
        .collection(DatabaseConstants.shoppingList)
        .doc(listItemId)
        .update({'quantity': quantity});
  }

  // Get all stores as a query snapshot.
  Future<QuerySnapshot> getStoreListQuery() {
    return storeCollection.get();
  }

  // Converts a list of queries into a list of store objects.
  List<Store> queryToStoreList(List<QueryDocumentSnapshot> queryList) {
    return queryList.map((QueryDocumentSnapshot snapshot) {
      Map<String, dynamic> store = snapshot.data();

      return Store(
          id: snapshot.id,
          name: store['name'],
          streetAddress: store['streetAddress'],
          city: store['city'],
          state: store['state'],
          zipCode: store['zipCode']);
    }).toList();
  }

  Stream<QuerySnapshot> getStoresStreamFromZipCode(String zipCode) {

    return storeCollection
      .where('zipCode', isEqualTo: zipCode)
      .snapshots();
  }

  Stream<QuerySnapshot> getStoreItemsStreamFromBarcodes(String storeId, List<String> barcodes) {

    return storeCollection
      .doc(storeId)
      .collection(DatabaseConstants.storeItems)
      .where('barcode', whereIn: barcodes)
      .orderBy('name')
      .snapshots();
  }

  // Converts a list of queries into a list of storeItem objects.
  List<StoreItem> queryToStoreItemList(List<QueryDocumentSnapshot> queryList) {


    return queryList.map((QueryDocumentSnapshot snapshot) {
      Map<String, dynamic> storeItem = snapshot.data();

      return StoreItem(
        storeItemId: snapshot.id,
        itemId: storeItem['itemId'],
        name: storeItem['name'],
        barcode: storeItem['barcode'],
        onSale: storeItem['onSale'],
        pictureUrl: storeItem['pictureUrl'],
        price: storeItem['price'],
        lastUserId: storeItem['userId'],
        lastUpdate: storeItem['dateUpdated'].toDate()
      );
    }).toList();
  }

  // Get the most current shopping list as a shopping list object
  Future<ShoppingList> getCurrentShoppingList() async {

    QuerySnapshot querySnapshot = await userCollection
      .doc(uid)
      .collection(DatabaseConstants.shoppingList)
      .get();
    
    return ShoppingList(items: queryToListItemList(querySnapshot.docs));
  }

  // Converts a list of queries into a list of listItem objects.
  List<ListItem> queryToListItemList(List<QueryDocumentSnapshot> queryList) {

    return queryList.map((QueryDocumentSnapshot snapshot) {
      Map<String, dynamic> storeItem = snapshot.data();

      return ListItem(
        listItemId: snapshot.id,
        itemId: storeItem['itemId'],
        name: storeItem['name'],
        barcode: storeItem['barcode'],
        pictureUrl: storeItem['image'],
        quantity: storeItem['quantity']
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
