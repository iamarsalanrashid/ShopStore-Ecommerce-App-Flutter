import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // to avoid name clashes

import './product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // )
  ];

  // var _showFavouritesOnly= false;
  String? authToken = '';
  String? userId = '';
  List<Product> myList = [];

  void update(String? myToken, String? id, myList) {
    authToken = myToken;
    userId = id;
    _items = myList;
  }

  List<Product> get items {
    return [..._items];
    // if(_showFavouritesOnly) {
    // return _items.where((prodItem) => prodItem.isFavourite).toList();
    // }
  }

  List<Product> get favouriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => id == prod.id);
  }

  Future<void> fetchAndSetProducts([bool filterUser = false]) async {
    final filterString = filterUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';

    final url = Uri.parse(
        'https://flutter-shop-app-9f1aa-default-rtdb.firebaseio.com/products.json?auth=$authToken$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      print(extractedData);
      if (extractedData == null) {
        return;
      }
      final favUrl = Uri.parse(
          'https://flutter-shop-app-9f1aa-default-rtdb.firebaseio.com/userFavourites/$userId.json?auth=$authToken');
      final favouriteResponse = await http.get(favUrl);
      final favouriteData = json.decode(favouriteResponse.body);
      final List<Product> loadedProducts = [];
      print('my auth token =$authToken');
      extractedData.forEach(
        (key, value) {
          loadedProducts.add(
            Product(
              id: key as String,
              title: value['title'],
              description: value['description'],
              price: value['price'],
              imageUrl: value['imageUrl'],
              isFavourite: favouriteData[key] == null
                  ? false
                  : favouriteData[key] ??
                      false, // double question mark means if previous statement yields null it will return null.
            ),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://flutter-shop-app-9f1aa-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId': userId,
        }),
      );
      print(json.decode(response.body));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'] as String,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    } // _items.insert(0, newProduct); // at the start of the list
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-shop-app-9f1aa-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'id': newProduct.id,
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'isFavourite': newProduct.isFavourite,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://flutter-shop-app-9f1aa-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[
        existingProductIndex]; // after being removed the product still remains in the memory
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException(
          'Could not delete product'); //throw is like return and finishes the function execution.
    }
  }

//   void showFavouritesOnly() {
//     _showFavouritesOnly = true;
//     notifyListeners();
// }
// void showAll() {
//     _showFavouritesOnly = false;
//     notifyListeners();
}
