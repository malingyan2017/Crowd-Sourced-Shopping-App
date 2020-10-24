import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shopping_app/Constants/database_constants.dart';
import 'package:shopping_app/Models/item.dart';
import 'package:shopping_app/Models/review.dart';
import 'package:shopping_app/Models/store.dart';
import 'package:shopping_app/Models/store_item.dart';
import 'package:shopping_app/Models/the_user.dart';

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
  Future addToCart(String itemId, String name, String image) async {
    return await FirebaseFirestore.instance
        .collection('item')
        .doc(uid)
        .collection('shoppingList')
        .doc()
        .set({'name': name, 'image': image, 'itemId': itemId});
  }

  //create if not there or update the user data in data base
  Future updateUsers(String username, int rank, String location) async {
    return await userCollection.doc(uid).set({
      'username': username,
      'rankPoints': rank,
      'location': location,
    });
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
      'userId': uid,
      'rating': review.rating,
      'dateWritten': review.dateCreated,
      'body': review.body
    });
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

  // Resturns the user's shopping list as a stream.
  Stream<QuerySnapshot> getShoppingList() {
    return userCollection
        .doc(uid)
        .collection(DatabaseConstants.shoppingList)
        .snapshots();
  }

  Future<void> removeShoppingListItem() {}
}
