// This page is for functions that may be needed in multiple files of our project.

import 'package:shopping_app/Models/list_item.dart';
import 'package:shopping_app/Models/shopping_list.dart';
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