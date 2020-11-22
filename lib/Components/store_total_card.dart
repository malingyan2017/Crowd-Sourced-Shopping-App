import 'package:flutter/material.dart';
import 'package:shopping_app/Models/store.dart';

class StoreTotalCard extends StatelessWidget {

  final Store store;
  final double total;
  final Color tileColor;
  final Widget trailing;
  final Function() onTap;

  StoreTotalCard({
    Key key, 
    this.store, 
    this.total, 
    this.tileColor,
    this.trailing, 
    this.onTap}
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        tileColor: tileColor,
        title: Text('${store.name} - ${store.streetAddress}'),
        subtitle: Text('Total Price \$${total.toStringAsFixed(2)}'),
        trailing: trailing,
        onTap: onTap
      ),
    );
  }
}