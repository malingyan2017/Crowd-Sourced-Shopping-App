import 'package:shopping_app/Models/item.dart';

class StoreItem extends Item{

  double price;
  bool onSale;
  String lastUser;
  DateTime lastUpdate;

  StoreItem(
    {
      int barcode, 
      String name, 
      String pictureUrl,
      this.price, 
      this.onSale, 
      this.lastUser, 
      this.lastUpdate
    }
  ) : super(barcode: barcode, name: name, pictureUrl: pictureUrl);

  String print() {

    return ''' 
      barcode: $barcode,
      name: $name,
      picture's url: $pictureUrl,
      price: $price,
      last user to update: $lastUser,
      last date of update: $lastUpdate
    ''';
  }
}
