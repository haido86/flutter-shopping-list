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
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        color: groceryItems[index].category.color,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Text(
                        groceryItems[index].name,
                      ),
                    ],
                  ),
                  Text(
                    groceryItems[index].quantity.toString(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
