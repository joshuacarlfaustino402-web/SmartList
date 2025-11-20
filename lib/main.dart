
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingListProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// #region Providers and Models
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class ShoppingListProvider with ChangeNotifier {
  List<ShoppingList> _lists = [];
  List<ShoppingList> get lists => _lists;

  ShoppingListProvider() {
    _loadLists();
  }

  Future<void> _loadLists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? listsString = prefs.getString('shopping_lists');
    if (listsString != null) {
      final List<dynamic> listsJson = jsonDecode(listsString);
      _lists = listsJson.map((json) => ShoppingList.fromJson(json)).toList();
    } else {
      _lists = [];
    }
    notifyListeners();
  }

  Future<void> _saveLists() async {
    final prefs = await SharedPreferences.getInstance();
    final String listsString = jsonEncode(_lists.map((list) => list.toJson()).toList());
    await prefs.setString('shopping_lists', listsString);
  }

  void addList(ShoppingList list) {
    _lists.add(list);
    _saveLists();
    notifyListeners();
  }

  void deleteList(int index) {
    _lists.removeAt(index);
    _saveLists();
    notifyListeners();
  }
}

class ShoppingList {
  String name;
  String category;
  List<ShoppingItem> items;

  ShoppingList({required this.name, required this.category, required this.items});

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      name: json['name'],
      category: json['category'],
      items: (json['items'] as List).map((i) => ShoppingItem.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'items': items.map((i) => i.toJson()).toList(),
      };

  double get totalPrice => items.fold(0, (sum, item) => sum + item.price);
}

class ShoppingItem {
  String name;
  double price;

  ShoppingItem({required this.name, required this.price});

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      name: json['name'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
      };
}
// #endregion

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.deepPurple;

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.bold,
          color: Colors.black
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            color: Colors.white
        ),
      ),
       inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SmartList',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const ShoppingListPage(),
        );
      },
    );
  }
}

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final Map<String, List<ShoppingList>> groupedLists = {};
    for (var list in shoppingListProvider.lists) {
      if (groupedLists[list.category] == null) {
        groupedLists[list.category] = [];
      }
      groupedLists[list.category]!.add(list);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartList'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: shoppingListProvider.lists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text('No shopping lists yet.', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Tap the + button to create your first list!', style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: groupedLists.keys.length,
              itemBuilder: (context, index) {
                final category = groupedLists.keys.elementAt(index);
                final lists = groupedLists[category]!;
                return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ExpansionTile(
                    title: Text(category, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    children: lists.map((list) {
                      return ListTile(
                        title: Text(list.name, style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text('Total: ₱${list.totalPrice.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () {
                            final listIndex = shoppingListProvider.lists.indexOf(list);
                            shoppingListProvider.deleteList(listIndex);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditListPage()),
          );
        },
        tooltip: 'New List',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditListPage extends StatefulWidget {
  const EditListPage({super.key});

  @override
  _EditListPageState createState() => _EditListPageState();
}

class _EditListPageState extends State<EditListPage> {
  final _listNameController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _categoryController = TextEditingController();
  final List<ShoppingItem> _items = [];

  void _addItem() {
    if (_itemNameController.text.isNotEmpty && _itemPriceController.text.isNotEmpty) {
      setState(() {
        _items.add(ShoppingItem(
          name: _itemNameController.text,
          price: double.tryParse(_itemPriceController.text) ?? 0.0,
        ));
        _itemNameController.clear();
        _itemPriceController.clear();
      });
    }
  }

  void _saveList() {
    if (_listNameController.text.isEmpty || _categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a List Name and a Category before saving.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newList = ShoppingList(
      name: _listNameController.text,
      category: _categoryController.text,
      items: _items,
    );
    Provider.of<ShoppingListProvider>(context, listen: false).addList(newList);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Shopping List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _listNameController,
              decoration: const InputDecoration(labelText: 'List Name', hintText: 'e.g., Weekly Groceries'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category', hintText: 'e.g., Home, Work, Personal'),
            ),
            const SizedBox(height: 30),
            Text('Add Items', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _itemNameController,
                    decoration: const InputDecoration(hintText: 'Item Name'),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _itemPriceController,
                    decoration: const InputDecoration(hintText: 'Price'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 30),
                  onPressed: _addItem,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('No items added yet.'))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text('₱${item.price.toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                setState(() {
                                  _items.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveList,
        label: const Text('Save List'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
