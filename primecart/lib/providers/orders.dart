import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './cart.dart';
import './products.dart';

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

  Future<void> fetchAndSetOrders() async {
    final response = await http.get(Products().url + '/orders.json');
    print(json.decode(response.body));
    final List<orderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if(extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(orderItem(
        id: orderId,
        amount: orderData['amount'],
        dateTime: DateTime.parse(orderData['dateTime']),
        products: (orderData['products'] as List<dynamic>).map((item) => CartItem(
          id: item['id'], 
          title: item['title'], 
          quantity: item['quantity'], 
          price: item['price'],
          )).toList(),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timeStamp = DateTime.now();
    final response = await http.post(
      Products().url + '/orders.json',
      body: json.encode({
        'amount': total,
        'dataTime': timeStamp.toIso8601String(),
        'products': cartProducts.map((cp) => {
          'id': cp.id,
          'title': cp.title,
          'quantity': cp.quantity,
          'price': cp.price,
        }).toList(),
      })
    );
    _orders.insert(0, orderItem(
      id: json.decode(response.body)['name'], 
      amount: total, 
      products: cartProducts, 
      dateTime: timeStamp,
    ),);
    notifyListeners();
  }
}