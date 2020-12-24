import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'SOJANYA',
    //   description: 'Men Grey & Black Self Design Kurta with Churidar',
    //   price: 1074,
    //   imageUrl:
    //       'https://assets.myntassets.com/h_1440,q_90,w_1080/v1/assets/images/6518468/2018/5/23/c18ee8eb-06f6-4d10-8f4a-680ac10fccf21527055151093-Sojanya-Since-1958-Grey-Silk-Kurta-Pyjama--Blue-Printed-Nehru-Jacket-SET-4231527055150856-1.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Puma',
    //   description: 'Unisex Grey Cappela IDP Slip-On Sneakers',
    //   price: 1649,
    //   imageUrl:
    //       'https://assets.myntassets.com/h_1440,q_90,w_1080/v1/assets/images/10252919/2019/10/31/74373232-d774-41dd-8b1e-5d7f218a2b931572515900769-Puma-Unisex-Grey-Cappela-IDP-Slip-On-Sneakers-57015725158993-1.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Cation',
    //   description: 'Women Black Solid Top',
    //   price: 479,
    //   imageUrl:
    //       'https://assets.myntassets.com/h_1440,q_90,w_1080/v1/assets/images/productimage/2018/12/11/0e1ef769-03ce-4733-a1e2-53434a8326841544520569693-1.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'Catwalk',
    //   description: 'Women Black Solid Sandals',
    //   price: 49.99,
    //   imageUrl:
    //       'https://assets.myntassets.com/h_1440,q_90,w_1080/v1/assets/images/4454079/2018/9/26/730c345e-3af8-460f-a6d1-f00659f302701537967512218-Catwalk-Women-Black-Solid-Sandals-6511537967511379-1.jpg',
    // ),
    // Product(
    //   id: 'p5',
    //   title: 'Bene Kleed',
    //   description: 'Men Off-White & Blue Slim Fit Printed Casual Shirt',
    //   price: 671,
    //   imageUrl:
    //       'https://assets.myntassets.com/h_1440,q_90,w_1080/v1/assets/images/7189947/2018/8/30/b0a17130-00b2-47dd-9acf-75fcdf7333111535614137835-Bene-Kleed-Men-Off-White--Blue-Slim-Fit-Printed-Casual-Shirt-3181535614137565-1.jpg',
    // ),
    // Product(
    //   id: 'p6',
    //   title: 'Nike',
    //   description: 'Men White AIR MAX EXCEE Sneakers',
    //   price: 5179,
    //   imageUrl:
    //       'https://assets.myntassets.com/h_1440,q_90,w_1080/v1/assets/images/11652318/2020/9/11/20868eb3-b5df-4d7e-9b94-70d0288457f11599794496021-Nike-Men-White-AIR-MAX-EXCEE-Sneakers-7661599794494910-1.jpg',
    // ),
    // Product(
    //   id: 'p7',
    //   title: 'LaFille',
    //   description: 'Beige Solid Shoulder Bag',
    //   price: 987,
    //   imageUrl:
    //       'https://assets.myntassets.com/h_1440,q_90,w_1080/v1/assets/images/productimage/2020/2/25/ff589a61-9395-4385-8435-cc634d1317431582585062898-1.jpg',
    // ),
    // Product(
    //   id: 'p8',
    //   title: 'GAP',
    //   description: 'Girls Off-White Printed Hooded Sweatshirt',
    //   price: 1499,
    //   imageUrl:
    //       'https://assets.myntassets.com/h_1440,q_90,w_1080/v1/assets/images/12648052/2020/12/11/ff975a5a-2eeb-4efb-ac8d-c9fc6da897c41607686634642-GAP-Girls-Off-White-Printed-Hooded-Sweatshirt-98116076866316-1.jpg',
    // ),
  ];
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if(_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product finById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  final url = "https://primecart-app-default-rtdb.firebaseio.com";

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    try{
      final response = await http.get(
        'https://primecart-app-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString'
      );
      // print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData == null) {
        return;
      }
      final favResponse = await http.get(
        url + '/userFavorites/' + userId + '.json?auth=' + authToken,
      );
      final favData = json.decode(favResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          imageUrl: prodData['imageUrl'],
          price: prodData['price'],
          isFavorite: favData == null 
          ? false
          : favData[prodId]
          ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw(error);
    }
  }

  Future<void> addProduct(Product product) async {
    try{
      final response = await http.post(url + '/products.json?auth=' + authToken, body: json.encode({
        'title': product.title,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'creatorId': userId, 
      }),
    );
    print(json.decode(response.body));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); //to add at start
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }

  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if(prodIndex >= 0) {
      await http.patch(
        url + '/products/' + id + '.json?auth=' + authToken,
        body: json.encode({
          'title': newProduct.title,
          'descripton': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
    else {
      print('Invalid');
    }
  }

  Future<void> deleteProduct(String id) async {
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    _items.insert(existingProductIndex, existingProduct);
    notifyListeners();
    final response = await http.delete(
      url + '/products/' + id + '.json?auth=' + authToken,
    );
    if(response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}