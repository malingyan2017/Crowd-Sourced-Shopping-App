import 'package:shopping_app/Models/item.dart';

class ShoppingList {

  List<ListItem> items = [];

  ShoppingList({this.items});

  void addItem(ListItem item) {
    
    items.add(item);
  }

  void removeItemById(String id) {

    items.removeWhere(
      (element) => element.itemId == id
    );
  }
}