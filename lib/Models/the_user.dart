import 'package:shopping_app/Models/shopping_list.dart';

class TheUser {
  final String uid;
  final String username;
  final String userRank;
  final String rankIconUrl;
  final int preferredLocation;
  final int preferredStoreId;
  ShoppingList shoppingList;

  TheUser(
    {
      this.uid, 
      this.username,
      this.userRank, 
      this.rankIconUrl, 
      this.preferredLocation, 
      this.preferredStoreId,
      this.shoppingList
    }
  );
}
