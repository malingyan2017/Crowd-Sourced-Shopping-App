import 'package:shopping_app/Models/shopping_list.dart';
import 'package:shopping_app/Models/store.dart';

class TheUser {

  static const List<String> rankings = 
    ['Novice', 'Journeyman', 'Master'];

  String uid;
  String username;
  int rankPoints;
  String rankIconUrl;
  Store preferredStore;
  ShoppingList shoppingList;

  TheUser(
      {this.uid,
      this.username,
      this.rankPoints, 
      this.rankIconUrl, 
      this.preferredStore,
      this.shoppingList
    }
  );

  String get userRank {

    return 'ADD LOGIC';
  }
}
