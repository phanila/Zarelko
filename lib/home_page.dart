import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:zarelko/database/data_structures.dart';
import 'package:zarelko/database/database.dart';
import 'app_extensions.dart';
import 'database/powersync.dart';
import 'main.dart';

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  String searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // StreamBuilder
          Expanded(
              child: StreamBuilder(
                stream: appDb.getAllFoodWithProductInfo(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error from database: ${snapshot.error}");
                  }

                  List<FoodWithProductInfo>? foodList = snapshot.data;
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return LinearProgressIndicator();
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (foodList!.isNotEmpty) {
                        foodList = foodList.where((item) =>
                            item.food.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                            item.food.desc!.toLowerCase().contains(searchQuery.toLowerCase())
                        ).toList();
                        foodList.sort((a, b) => a.finalDate.compareTo(b.finalDate));

                        // Group items by finalDate
                        var groupedByDate = <DateTime, List<FoodWithProductInfo>>{};
                        for (var food in foodList) {
                          final date = food.finalDate;
                          if (groupedByDate[date] == null) {
                            groupedByDate[date] = [];
                          }
                          groupedByDate[date]!.add(food);
                        }

                        // Sort the keys to get the final dates in order
                        var sortedDates = groupedByDate.keys.toList()..sort();

                        return ListView.builder(
                          itemCount: sortedDates.length,
                          itemBuilder: (context, index) {
                            var date = sortedDates[index];
                            var foodItems = groupedByDate[date]!;

                            // Display the final date as a header
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    DateFormat("EEEE dd.MM.yyyy").format(date),
                                    style: TextStyle(
                                      fontSize: 18,
                                      // fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                // List the food items for this finalDate
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: foodItems.length,
                                  itemBuilder: (context, itemIndex) {
                                    return FoodListTile(element: foodItems[itemIndex]);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }

                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image(image: AssetImage("assets/nofood.jpg")),
                        ),
                      );
                  }
                },
              )
          )
        ]
    );
  }
}

class FoodListTile extends StatelessWidget {
  const FoodListTile({super.key, required this.element});

  final FoodWithProductInfo element;

  @override
  Widget build(BuildContext context) {
    var color = Colors.white;
    var isOpened = element.food.openingDate == null;
    if (DateTime.now().isAfter(element.finalDate)) {
      color = Colors.red;
    } else if (element.finalDate.difference(DateTime.now()).inDays < 7) {
      color = Colors.amber;
    }
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: DrawerMotion(),
          children: [
            SlidableAction(
              //borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
              onPressed: (context) {
                navigateAndDisplayAddPage(context, 0, element.product, element.food, true);
              },
              backgroundColor: Color(0xFF0392CF),
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              //borderRadius: BorderRadius.horizontal(right: Radius.circular(15)),
              onPressed: (context) => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Surely, you can\'t be serious'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Don\'t call me Shirley', style: TextStyle(fontSize: 12)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        var player = AudioPlayer();
                        player.play(AssetSource("EatingSound.mp3"));
                        appDb.deleteFoodRecord(element.food.id);
                        Navigator.pop(context);
                      },
                      child: const Text('I am serious', style: TextStyle(fontSize: 12)),
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
        child: Container(
          color: color,
          child: ListTile(
            title:
                Text(
                  element.food.name.capitalize(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
            subtitle: Text("${element.food.desc!}\n${element.finalPlace}"),
            trailing: isOpened
                ? TextButton(
              onPressed: () {
                FoodsCompanion newFood = element.food.toCompanion(false).copyWith(openingDate: Value(DateTime.now().zeroTime()));
                appDb.updateFoodRecord(id: element.food.id, food: newFood);
              },
              child: Text("Open"),
            )
                : null,
          ),
        ),
      ),
    );
  }
}
