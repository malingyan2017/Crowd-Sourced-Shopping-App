import 'package:shopping_app/Models/item.dart';

class StoreItem extends Item {

  String storeItemId;
  double price;
  bool onSale;
  String lastUserId;
  DateTime lastUpdate;
  int quantity;

  StoreItem(
    {
      String itemId,
      String barcode, 
      String name, 
      String pictureUrl,
      List<String> tags,
      this.storeItemId,
      this.price, 
      this.onSale, 
      this.lastUserId, 
      this.lastUpdate,
      this.quantity
    }
  ) : super(itemId: itemId, barcode: barcode, name: name, pictureUrl: pictureUrl, tags: tags);

  // For testing
  String print() {

    return ''' 
      barcode: $barcode,
      name: $name,
      picture's url: $pictureUrl,
      price: $price,
      last user to update: $lastUserId,
      last date of update: $lastUpdate
    ''';
  }
}
