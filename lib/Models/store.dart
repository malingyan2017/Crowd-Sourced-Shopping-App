import 'package:shopping_app/Models/review.dart';
import 'package:shopping_app/Models/store_item.dart';

class Store { 

  String id;
  String name;
  String streetAddress;
  String city;
  String state;
  String zipCode;
  List<StoreItem> items = [];
  List<Review> reviews = [];

  Store(
    {
      this.id, 
      this.name, 
      this.streetAddress, 
      this.city, 
      this.state, 
      this.zipCode,
      this.items,
      this.reviews
    }
  );

  Store.storeFromMap(Map<String, dynamic> data) {

    id = data['id'];
    name = data['name'];
    streetAddress = data['streetAddress'];
    city = data['city'];
    state = data['state'];
    zipCode = data['zipCode'];
  }

  String get fullAddress {

    return '''$name
              $streetAddress
              $city, $state $zipCode''';
  }

  String get cityStateZip {

    return '$city, $state $zipCode';
  }

  String get nameWithStreetAddress {

    return '$name\n$streetAddress';
  }

}