import 'package:flutter/material.dart';
import 'dart:core';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:zarelko/database/database.dart';
import 'package:zarelko/main.dart';
import 'database/powersync.dart';

class ProductPageBody extends StatelessWidget {
  const ProductPageBody({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: appDb.getAllProducts(), builder: (context,snapshot) {
      if (snapshot.hasError){
        return Text("Error from database");
      }
      List<Product>? productList = snapshot.data;
      switch(snapshot.connectionState){
        case ConnectionState.waiting:
        case ConnectionState.none:
          return LinearProgressIndicator();
        case ConnectionState.active:
        case ConnectionState.done:
          return productList!.isEmpty ? Center(
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child:Image(image: AssetImage("assets/nofood.jpg")
                  )
              )
          ) :
          Center(
              child: ListView.builder(
                  itemCount: productList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ProductListTile(product: productList[index]);
                  }
              )
          );}
    });
  }

}
class ProductListTile extends StatelessWidget {
  const ProductListTile({super.key, required this.product});

  final Product product;
  @override
  Widget build(BuildContext context) {
    var color = Colors.white;
    return Padding(
      padding: const EdgeInsets.all(10),

      child: Slidable(
          endActionPane: ActionPane(
            motion: DrawerMotion(),
            children: [
              SlidableAction(
                borderRadius: BorderRadius.horizontal(left:Radius.circular(15)),
                onPressed: (context) {
                  navigateAndDisplayAddPage(context, 1, product,true);
                },
                backgroundColor: Color(0xFF0392CF),
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),
              SlidableAction(
                borderRadius: BorderRadius.horizontal(right:Radius.circular(15)),
                onPressed: (context) => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Are you sure?'),
                    content: FutureBuilder(
                      future: appDb.allFoodOfThisProduct(product.name),
                      builder: (context,snapshot) {
                        if (snapshot.hasError) {
                          return Text("Error from database");
                        }
                        List<String>? foodsOfProduct = snapshot.data;
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return LinearProgressIndicator();
                          case ConnectionState.active:
                          case ConnectionState.done:
                            if (foodsOfProduct == null || foodsOfProduct.isEmpty) {
                              return Text("No food affected");
                            }
                            return Text("${foodsOfProduct.length} food affected\n - ${foodsOfProduct.join("\n - ")}\n You will delete all of them");
                        }
                      }),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          appDb.deleteProductRecord(product.name);
                          Navigator.pop(context);},
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                ),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: 'Delete',
              ),
            ],
          ),
          child: Card(
              color: color,
              child:ListTile(
                  title:Text(product.name),
                  subtitle: Text("Where:${product.storingLocation!}, opened:${product.openLocation!}"),
                  trailing: Text("How many days can be opened: ${product.openLife}")
              )
          )
      ),
    );
  }
}