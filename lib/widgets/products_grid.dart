import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './product_item.dart';
import '../providers/products.dart';

class ProductsGrid extends StatelessWidget {
final bool showFavs;

ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context,listen: true);// access Products class
    final products =showFavs ? productsData.favouriteItems : productsData.items;// acces the method and properites of Products class
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10),

      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value :products[index],   //adding listener to each Product item
        child: ProductItem(

            // products[i].title, products[i].id, products[i].imageUrl

            ),
      ) ,
      itemCount: products.length,
    );
  }
}
