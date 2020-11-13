import 'package:shopping_app/Models/list_item.dart';

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

  List<String> barcodeList() {

    List<String> barcodes = [];

    items.forEach((element) {
      barcodes.add(element.barcode);
    });

    return barcodes;
  }
}