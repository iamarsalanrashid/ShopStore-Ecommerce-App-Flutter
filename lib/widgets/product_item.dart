import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail_screen.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String title;
  // final String imageUrl;
  // final String id;
  // ProductItem(this.title, this.id, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context,
        listen: true); // IMP: access each item in Products class which is just a model with assigned values
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                  arguments: product.id);
            },
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder: AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl,),
                fit: BoxFit.cover,
              ),
            )
      ),
      footer: GridTileBar(
        backgroundColor: Colors.black26,
        leading: Consumer<Product>(
          builder: (ctx, product, child) =>
              IconButton(
                  icon: Icon(product.isFavourite
                      ? Icons.favorite
                      : Icons.favorite_outline),
                  onPressed: () {
                    product.toggleFavouriteStatus(
                        authData.token as String, authData.userId as String);
                  },
                  color: Theme
                      .of(context)
                      .colorScheme
                      .secondary),
        ),
        title: Text(
          product.title,
          textAlign: TextAlign.center,
        ),
        trailing: IconButton(
          icon: Icon(Icons.shopping_cart),
          onPressed: () {
            cart.addItem(product.id, product.price, product.title);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 2),
                content: Text(
                  'Added item to the Cart! ',
                  textAlign: TextAlign.center,
                ),
                action: SnackBarAction(label: 'UNDO', onPressed: () {
                  cart.removeSingleItem(product.id as String);
                },
                ),
              ),
            );
          },
          color: Theme
              .of(context)
              .colorScheme
              .secondary,
        ),
      ),
    )
    ,
    );
  }
}
