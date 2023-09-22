import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_item.dart';

class GroceryListScreen extends StatelessWidget {
  const GroceryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your groceries',
        ),
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (context, index) => ListTile(
          leading: Container(
            color: groceryItems[index].category.color,
            width: 24,
            height: 24,
          ),
          title: Text(
            groceryItems[index].name,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          trailing: Text(
            groceryItems[index].quantity.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
