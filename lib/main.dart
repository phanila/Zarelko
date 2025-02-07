import 'package:flutter/material.dart';
import 'dart:core';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Zarelko'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        actions:[ElevatedButton(
          onPressed:(){},
          child:Icon(Icons.add_box),
        )],
      ),
      body: Center(
      child: ListView(
      children: <Widget>[
      FoodListTile(food:
      Food('test', 'testowy',DateTime.parse('1969-07-20 20:18:04Z'),"TestType","Nowhere")
      ),
      ],
    ),
    ),
    );
  }
}
class FoodListTile extends StatelessWidget {
  const FoodListTile({super.key, required this.food});

  final Food food;
  @override
  Widget build(BuildContext context) {
    return Card(
    child: Padding(
        padding: const EdgeInsets.all(20),

    child: ExpansionTile(
      title:Wrap(
        spacing:2,
        children :[Text(food.name),
          Text(food.type),
          Text(food.expiry_date.toString())
        ]
      ),
      children: [
      Text(food.desc),
        Text(food.location)
      ]
    ),
    )
    );
  }
}
class Food {
  final String name;
  final String desc;
  final String type;
  final String location;
  final DateTime expiry_date;
  Food(this.name, this.desc, this.expiry_date, this.type,this.location);

}
