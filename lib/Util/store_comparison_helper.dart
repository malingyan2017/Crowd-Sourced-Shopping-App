// This page is for functions that may be needed in multiple files of our project.

import 'package:shopping_app/Models/list_item.dart';
import 'package:shopping_app/Models/shopping_list.dart';
import 'package:shopping_app/Models/store.dart';
import 'package:shopping_app/Models/store_item.dart';

// Calculates the total price of a list of store items.
// Uses the shopping list to attach a quantity to a given store item in order
// to calculate the total correctly.
double getTotalPrice(List<StoreItem> storeItems, ShoppingList shoppingList) {

  double total = 0;

  storeItems.forEach((StoreItem storeItem) {

    ListItem listItem = 
      shoppingList.items.firstWhere(
        (element) => element.barcode == storeItem.barcode,
        orElse: () => null
      );
    
    storeItem?.quantity = listItem?.quantity;

    total += storeItem.price * storeItem.quantity;
  });

  return total;
}

// Returns a StalenessStruct containing any relevant information related to
// the staleness of the items for this store.
// Contains the "total" difference between the time passed in and the last time
// that every individual item was updated represented as a DateTime.
// The number of stale items and the percentage of stale items are provided
// to help determine staleness.
// The store must be filled with storeItems.
StalenessStruct getStoreStalenessInfo(Store store) {

  DateTime dateToReturn = DateTime.now();
  int staleItemCount = 0;

  store.items.forEach((StoreItem currentStore) { 

    Duration difference = dateToReturn.difference(currentStore.lastUpdate);

    dateToReturn = dateToReturn.subtract(difference);

    if (isStale(currentStore)) {

      staleItemCount++;
    }
  });

  return StalenessStruct(
    dateToReturn,
    staleItemCount, 
    staleItemCount / store.items.length
  );

}

// Returns whether or not this item's price information is stale.
// This is arbitrary, but having this as its own function means I can change
// the definition of "staleness" easily.
bool isStale(StoreItem storeItem) {

  // Our threshold is three weeks before we consider pricing information stale.
  DateTime limit = DateTime.now().subtract(Duration(days: 21));

  return storeItem.lastUpdate.isBefore(limit);
}

class StalenessStruct {

  DateTime time;
  int staleItemCount;
  double stalePercentage;

  StalenessStruct(this.time, this.staleItemCount, this.stalePercentage);
}