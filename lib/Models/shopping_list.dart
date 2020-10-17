import 'package:shopping_app/Models/item.dart';

class ShoppingList {

  List<Item> items = [];

  ShoppingList({this.items});

  void addItem(Item item) {
    
    items.add(item);
  }

  void removeItemById(String id) {

    items.removeWhere(
      (element) => element.itemId == id
    );
  }
}