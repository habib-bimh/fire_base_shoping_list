import 'dart:convert';
import 'package:firebse_list_shoping/data/categories.dart';
import 'package:firebse_list_shoping/models/grocery_item.dart';
import 'package:firebse_list_shoping/widgets/new_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItem = [];
  @override
  void initState() {
    super.initState();
    _lodigItem();
  }

  void _lodigItem() async {
    final url = await Uri.https(
        "flutter-shoping-list-f17e7-default-rtdb.firebaseio.com",
        "shopping-list.json");
    final response = await http.get(url);
    final List<GroceryItem> _lodedItems = [];
    final Map<String, dynamic> listData = json.decode(response.body);
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value["category"])
          .value;
      _lodedItems.add(GroceryItem(
          id: item.key,
          name: item.value["name"],
          quantity: item.value["quantity"],
          category: category));
    }

    setState(() {
      _groceryItem = _lodedItems;
    });
  }

  void _addItem() async {
    final newList = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (context) => const NewItemScreen()));

    _lodigItem();
  }

  void _removedItem(GroceryItem item) {
    setState(() {
      _groceryItem.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("No item add yet.."),
    );
    if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItem.length,
          itemBuilder: (context, index) => Dismissible(
                onDismissed: (direction) {
                  _removedItem(_groceryItem[index]);
                },
                key: ValueKey(_groceryItem[index].id),
                child: ListTile(
                  title: Text(_groceryItem[index].name),
                  leading: Container(
                      height: 24,
                      width: 24,
                      color: _groceryItem[index].category.color),
                  trailing: Text(_groceryItem[index].quantity.toString()),
                ),
              ));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Grocery"),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
