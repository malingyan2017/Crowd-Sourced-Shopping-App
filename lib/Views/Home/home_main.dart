import 'package:flutter/material.dart';
import 'package:shopping_app/Views/Common/app_bar.dart';
import 'package:shopping_app/Views/Home/livefeed_reviews.dart';

import 'livefeed_price_updates.dart';

// Source: https://stackoverflow.com/questions/50609252/flutter-tabbar-without-appbar

class Home extends StatelessWidget {
  //const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: new Container(
            height: 50.0,
            child: new TabBar(
              tabs: [
                Tab(
                  child: Text(
                    'Price Updates',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Store Reviews',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            LivePriceUpdates(),
            LiveReviews(),
          ],
        ),
      ),
    );
  }
}
