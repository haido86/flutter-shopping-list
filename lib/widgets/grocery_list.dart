import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});
  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  // Key for the Scaffold to show SnackBars.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Load grocery items when the widget is initialized.
    _loadItems();
  }

  // Loads grocery items from the server and updates the UI.
  void _loadItems() async {
    final url = Uri.https(
      'flutter-app-d9fb0-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      // Handle errors and set the error message.
      setState(() {
        _error = 'Fail to fetch data. Please try again.';
      });
    }

    if (response.body == 'null') {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final List<GroceryItem> loadedItems = [];
    final Map<String, dynamic> listData = json.decode(response.body);
    for (final item in listData.entries) {
      // Map server data to GroceryItem objects.
      final Category category = categories.entries
          .firstWhere((cat) => cat.value.name == item.value['category'])
          .value;
      loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }

    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  // Adds a new grocery item to the list.
  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  // Removes a grocery item from the list and handles errors.
  void _removeItem(GroceryItem item) async {
    ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);

    final index = _groceryItems.indexOf(item);
    final itemName = item.name;
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https(
      'flutter-app-d9fb0-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        // Handle the error and reinsert the item.
        _groceryItems.insert(index, item);
      });
      // Show the SnackBar using ScaffoldMessenger.
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('$itemName can\'t be removed.'),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('$itemName is removed.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        'There is no item added.',
      ),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(
            _groceryItems[index].id,
          ),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          child: ListTile(
            leading: Container(
              color: _groceryItems[index].category.color,
              width: 24,
              height: 24,
            ),
            title: Text(
              _groceryItems[index].name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Your groceries',
        ),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: content,
    );
  }
}
