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