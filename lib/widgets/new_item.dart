import 'dart:convert';
import 'package:firebse_list_shoping/data/categories.dart';
import 'package:firebse_list_shoping/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  final _fromKey = GlobalKey<FormState>();
  var _enterndName = "";
  var _enterndQuenty = 1;
  var _seletedCatagori = categories[Categories.vegetables]!;

  void saveItem() async {
    if (_fromKey.currentState!.validate()) {
      _fromKey.currentState!.save();
      final url = Uri.https(
          "flutter-shoping-list-f17e7-default-rtdb.firebaseio.com",
          "shopping-list.json");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(
          {
            "name": _enterndName,
            "quantity": _enterndQuenty,
            "category": _seletedCatagori.title
          },
        ),
      );
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add new Item"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
              key: _fromKey,
              child: Column(
                children: [
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(
                      label: Text("Name"),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1 ||
                          value.trim().length > 50) {
                        return "Must be between 1 and 50 characters.";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enterndName = value!;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text("Quentity"),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: _enterndQuenty.toString(),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return " Must be valid, positive number";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enterndQuenty = int.parse(value!);
                        },
                      )),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: DropdownButtonFormField(
                            value: _seletedCatagori,
                            items: [
                              for (final category in categories.entries)
                                DropdownMenuItem(
                                    value: category.value,
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 16,
                                          width: 16,
                                          color: category.value.color,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(category.value.title)
                                      ],
                                    ))
                            ],
                            onChanged: (value) {
                              setState(() {
                                _seletedCatagori = value!;
                              });
                            }),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            _fromKey.currentState!.reset();
                          },
                          child: const Text("Reset")),
                      const SizedBox(),
                      ElevatedButton(
                          onPressed: () {
                            saveItem();
                          },
                          child: const Text("Add Item"))
                    ],
                  )
                ],
              )),
        ));
  }
}
