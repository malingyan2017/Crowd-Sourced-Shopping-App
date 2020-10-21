import 'package:shopping_app/Models/shopping_list.dart';

class TheUser {

  static const List<String> rankings = 
    ['Novice', 'Journeyman', 'Master'];

  final String uid;
  final String username;
  final int rankPoints;
  final String rankIconUrl;
  final int preferredLocation;
  final int preferredStoreId;
  ShoppingList shoppingList;

  TheUser(
    {
      this.uid, 
      this.username,
      this.rankPoints, 
      this.rankIconUrl, 
      this.preferredLocation, 
      this.preferredStoreId,
      this.shoppingList
    }
  );

  String get userRank {

    return 'ADD LOGIC';
  }
}
