import 'package:shopping_app/Models/shopping_list.dart';

class TheUser {

  static const List<String> rankings = 
    ['Novice', 'Journeyman', 'Master'];

  String uid;
  String username;
  int rankPoints;
  String rankIconUrl;
  String preferredStoreId;
  ShoppingList shoppingList;

  TheUser(
      {this.uid,
      this.username,
      this.rankPoints, 
      this.rankIconUrl, 
      this.preferredStoreId,
      this.shoppingList
    }
  );

  String get userRank {

    return 'ADD LOGIC';
  }
}
