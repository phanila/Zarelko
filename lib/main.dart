import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:zarelko/add_page.dart';
import 'package:zarelko/database/database.dart';
import 'app_extensions.dart';

void main() {
  runApp(Provider<AppDatabase>(
    create: (context) => AppDatabase(),
    child: MyApp(),
    dispose: (context, db) => db.close(),
  ),);
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
  //   var appState = context.watch<MyAppState>();
     var database = context.watch<AppDatabase>();
  //   Stream<List<FoodEntry>> foodList = await database.getAllFood();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions: [
          ElevatedButton(onPressed: (){}, child: Icon(Icons.sync))
        ],
      ),
      body: StreamBuilder(stream: database.getAllFood(), builder: (context,snapshot) {
        if (snapshot.hasError){
          return Text("Error from database");
        }
        List<FoodEntry>? foodList = snapshot.data;
        switch(snapshot.connectionState){
          case ConnectionState.waiting:
          case ConnectionState.none:
            return LinearProgressIndicator();
          case ConnectionState.active:
          case ConnectionState.done:
            return foodList!.isEmpty ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                  child:Image(image: AssetImage("assets/nofood.jpg")
               )
              )
            ) :
            Center(
              child: ListView.builder(
              itemCount: foodList.length,
              itemBuilder: (BuildContext context, int index) {
                return FoodListTile(food: foodList[index]);
              }
              )
        );}
      }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
          _navigateAndDisplayAddPage(context);
          },
          child: const Icon(Icons.add),
        ),

    );
  }
}
class FoodListTile extends StatelessWidget {
  const FoodListTile({super.key, required this.food});

  final FoodEntry food;
  @override
  Widget build(BuildContext context) {
    var database = context.watch<AppDatabase>();
    var color = Colors.white;
    if (DateTime.now().isAfter(food.expiryDate)){
      color = Colors.red;
    }
    else if (food.expiryDate.difference(DateTime.now()).inDays <= 7){
      color = Colors.amber;
    }
    return Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: ExpansionTile(
            title:Row(children: [Text(food.name.capitalize(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),Expanded(
              child: Container(),
            ),
              Text(DateFormat("E dd.MM.yyyy").format(food.expiryDate))]),
            subtitle: Text(food.category!),
            trailing: IconButton(onPressed: ()  => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Are you sure?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        database.deleteFoodRecord(food.id);
                        Navigator.pop(context);},
                      child: const Text('Yes'),
                    ),
                  ],
                ),
            ),
                    icon: Icon(Icons.delete_outline)
              ),
            children: [
            Text(food.desc!),
              Text(food.location!)
            ]
          ),
        )
    );
  }
}
Future<void> _navigateAndDisplayAddPage(BuildContext context) async {

  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AddPage()),
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
