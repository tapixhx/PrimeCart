import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  CartItem(
    this.id,
    this.productId,
    this.price,
    this.quantity,
    this.title
  );

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).primaryColor,
        child: Icon(
          Icons.delete, 
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 10),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      ),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
        elevation: 10,
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: FittedBox(child: Text(
                '\$$price',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),),
              ),
              title: Text(
                '$title',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('Total: \$${(price * quantity)}'),
              trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}