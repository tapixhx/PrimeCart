import 'package:flutter/material.dart';

import './screens/products_overview_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrimeCart',
      theme: ThemeData(
        primarySwatch: Colors.red,
        accentColor: Colors.redAccent,
        fontFamily: 'Montserrat',
      ),
      home: ProductsOverviewScreen(),
    );
  }
}