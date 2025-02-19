import 'package:flutter/material.dart';
import 'dart:core';
import 'package:zarelko/add_food.dart';
import 'package:zarelko/add_product.dart';
import 'package:zarelko/database/powersync.dart';
import 'homePage.dart';
import 'productPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //required to get sqlite filepath from path_provider before UI has initialized
  await openDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Żarełko',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: MyHomePage(title:'Żarełko'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var currentIndex = 0;
  @override
  Widget build(BuildContext context) {
  //   var appState = context.watch<MyAppState>();
   //  var database = context.watch<AppDatabase>();
  //   Stream<List<FoodEntry>> foodList = await database.getAllFood();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          ElevatedButton(onPressed: (){}, child: Icon(Icons.sync))
        ],
      ),
      body: [HomePageBody(), ProductPageBody()][currentIndex],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
          _navigateAndDisplayAddPage(context, currentIndex);
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar:NavigationBar(destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.warehouse_outlined),
            label: 'Products',
          ),
        ],
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          setState(() {currentIndex = index;});
        },),
    );
  }
}

Future<void> _navigateAndDisplayAddPage(BuildContext context, int currentIndex) async {
  final destAdd = [AddFoodPage(),AddProductPage()];
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => destAdd[currentIndex]),
  );

  if (!context.mounted) return;

  // After the Selection Screen returns a result, hide any previous snackbars
  // and show the new result.
  if(result != null) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Added food: $result')));
  }
}
