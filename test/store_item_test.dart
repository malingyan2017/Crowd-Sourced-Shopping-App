import 'dart:math';

import 'package:test/test.dart';
import 'package:shopping_app/Models/store_item.dart';

void main() {

  int barcode = 123;
  String name = 'test';
  String url = 'testurl';
  double price = 10.33;
  bool onSale = true;
  String lastUser = 'dummy1';
  DateTime lastUpdate = DateTime.parse("2020-02-27");

  StoreItem myItem = StoreItem(
    barcode: barcode, 
    name: name, 
    pictureUrl: url, 
    price: price, 
    onSale: onSale, 
    lastUser: lastUser, 
    lastUpdate: lastUpdate
  );
  
  test('All parent variables can be accessed.', () {

    // Parent variables
    expect(myItem.barcode, barcode);
    expect(myItem.name, name);
    expect(myItem.pictureUrl, url);

    // Child variables
    expect(myItem.price, price);
    expect(myItem.onSale, onSale);
    expect(myItem.lastUser, lastUser);
    expect(myItem.lastUpdate, lastUpdate);
  });

  
  test('Print method is able to display all information.', () {

    print(myItem.print());
  });
  
}