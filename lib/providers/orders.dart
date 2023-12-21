import 'dart:convert'; // to convert map into json
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({required this.id,
    required this.amount,
    required this.products,
    required this.dateTime});
}

class Orders with ChangeNotifier {
  String? myToken = '';
  String? userId = '';
  List<OrderItem> myOrders = [];
  void update (String? token ,String? id, myOrders){
    myToken = token;
    _orders = myOrders;
    userId = id;
  }
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://flutter-shop-app-9f1aa-default-rtdb.firebaseio.com/orders/$userId.json?auth=$myToken');
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': DateTime.now().toIso8601String(),
          //just a uniform representation of  string of DateTime which we can load it back into dart object when we fetch it agin

          'products': cartProducts
              .map((cp) =>
          {
            'id': cp.id,
            'title': cp.title,
            'price': cp.price as double,
            'quantity': cp.quantity
          })
              .toList(),
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'] as String,
        amount: total,
        products: cartProducts,
        //here list is used because user can place multiple orders with multiple items in each order.
        dateTime: timeStamp,
      ),
    );
    print('$_orders');
    notifyListeners();
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse(
        'https://flutter-shop-app-9f1aa-default-rtdb.firebaseio.com/orders/$userId.json?auth=$myToken');

    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    final List<OrderItem> loadedProducts = [];
    extractedData.forEach((orderId, orderData) {
      loadedProducts.add(OrderItem(
        id: orderId,
        amount: orderData['amount'],
        dateTime: DateTime.parse(orderData['dateTime']),
        products: (orderData['products'] as List<dynamic>)
            .map((cp) =>
            CartItem(id: cp['id'],
                title: cp['title'],
                quantity: cp['quantity'],
                price: cp['price'])).toList(),

      )
      );
    });
  }
}

