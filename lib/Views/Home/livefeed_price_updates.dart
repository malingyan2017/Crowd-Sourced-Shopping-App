import 'package:flutter/material.dart';
import 'package:shopping_app/Views/Common/app_bar.dart';

class LivePriceUpdates extends StatelessWidget {
  List<String> items = <String>[
    'price update 1',
    'price update 2',
    'price update 3',
    'price update 4',
    'price update 5',
    'price update 6',
    'price update 7',
    'price update 8',
    'price update 9',
    'price update 10',
    'price update 11',
    'price update 12'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('${items[index]}'),
          );
        },
      ),
    );
  }
}

/*itemCount: europeanCountries.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(europeanCountries[index]),
          );*/
