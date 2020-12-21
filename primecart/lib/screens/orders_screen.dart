import 'package:flutter/material.dart';
import 'package:primecart/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {

    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Order'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen:false).fetchAndSetOrders(),
        builder: (ctx, dataSnapshot) {
          if(dataSnapshot.connectionState == ConnectionState.waiting) {
            Center(
              child: CircularProgressIndicator()
            );    
          } else {
            if(dataSnapshot.error == null) {
              // ...
              Center(child: Text('An error occured!'));
            } else {
              return Consumer<Orders>(builder: (ctx, orderData, child) => ListView.builder(
                itemCount: orderData.orders.length,
                itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
              ),);
            }
          }
        },
      )
    );
  }
}