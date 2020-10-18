import 'package:test/test.dart';
import 'package:shopping_app/Models/store_item.dart';

void main() {
  int barcode = 123;
  String name = 'test';
  String url = 'testurl';
  double price = 10.33;
  bool onSale = true;
  List<String> tags = ['simple', 'testing'];
  String lastUserId = '1b123b';
  DateTime lastUpdate = DateTime.parse("2020-02-27");

  StoreItem myItem = StoreItem(
      barcode: barcode,
      name: name,
      pictureUrl: url,
      tags: tags,
      price: price,
      onSale: onSale,
      lastUserId: lastUserId,
      lastUpdate: lastUpdate);

  test('All parent variables can be accessed.', () {
    // Parent variables
    expect(myItem.barcode, barcode);
    expect(myItem.name, name);
    expect(myItem.pictureUrl, url);
    expect(myItem.tags[0], tags[0]);
    expect(myItem.tags[1], tags[1]);

    // Child variables
    expect(myItem.price, price);
    expect(myItem.onSale, onSale);
    expect(myItem.lastUserId, lastUserId);
    expect(myItem.lastUpdate, lastUpdate);
  });

  test('Print method is able to display all information.', () {
    print(myItem.print());

    List<String> practice;

    print('Practice contents: $practice');
  });
}
