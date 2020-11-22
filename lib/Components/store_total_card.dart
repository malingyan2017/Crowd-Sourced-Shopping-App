import 'package:flutter/material.dart';
import 'package:shopping_app/Models/store.dart';

class StoreTotalCard extends StatelessWidget {

  final Store store;
  final double total;
  final Color borderColor;
  final Widget trailing;
  final Function() onTap;

  StoreTotalCard({
    Key key, 
    this.store, 
    this.total, 
    this.borderColor,
    this.trailing, 
    this.onTap}
  ) : super(key: key);

  // https://stackoverflow.com/questions/50783354/how-to-highlight-the-border-of-a-card-selected
  // Covers how to add a colored border to the sides of a card.
  @override
  Widget build(BuildContext context) {

    ShapeBorder shape = borderColor != null 
    ? RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0), 
      side: BorderSide(
        color: borderColor,
        width: 2
      )
    )
    : null;

    // https://stackoverflow.com/questions/50783354/how-to-highlight-the-border-of-a-card-selected
    return Card(
      shape: shape,
      child: ListTile(
        title: Text('${store.name} - ${store.streetAddress}'),
        subtitle: Text('Total Price \$${total.toStringAsFixed(2)}'),
        trailing: trailing,
        onTap: onTap
      ),
    );
  }
}