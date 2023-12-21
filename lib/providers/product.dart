import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; //this means we bundle all the features of this package and can access them using "http."

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite; // not final because we want it mutable/changable.

  Product({required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavourite = false});


  Future<void> toggleFavouriteStatus(String token, String userId) async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;

    setFavValues(bool oldStatus) {
      isFavourite = oldStatus;
      notifyListeners();
    }
    final url = Uri.parse(
        'https://flutter-shop-app-9f1aa-default-rtdb.firebaseio.com/userFavourites/$userId/$id.json?auth=$token');
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavourite,
        ),
      );
      if (response.statusCode >= 400) {
        setFavValues(oldStatus);
      }
    } catch (error) {
      setFavValues(oldStatus);
    }

    notifyListeners();
  }
}
