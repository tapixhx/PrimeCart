import 'package:flutter/foundation.dart';

import './cart.dart';

class orderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  orderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime
  });
}

class Orders with ChangeNotifier {
  List<orderItem> _orders = [];

  List<orderItem> get orders {
    return [..._orders];
  }

  void addOrder(List<CartItem> cartProducts, double total) {
    _orders.insert(0, orderItem(id: DateTime.now().toString(), amount: total, products: cartProducts, dateTime: DateTime.now(),),);
    notifyListeners();
  }
}