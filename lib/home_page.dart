import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:zarelko/database/data_structures.dart';
import 'package:zarelko/database/database.dart';
import 'app_extensions.dart';
import 'database/powersync.dart';
import 'main.dart';

class HomePageBody extends StatelessWidget {
  const HomePageBody({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: appDb.getAllFoodWithProductInfo(), builder: (context,snapshot) {
      if (snapshot.hasError){
        return Text("Error from database: ${snapshot.error}");
      }
      List<FoodWithProductInfo>? foodList = snapshot.data;
      switch(snapshot.connectionState){
        case ConnectionState.waiting:
        case ConnectionState.none:
          return LinearProgressIndicator();
        case ConnectionState.active:
        case ConnectionState.done:
          if (foodList!.isNotEmpty) {
            foodList.sort((a, b) => a.finalDate.compareTo(b.finalDate));
          }
          return foodList.isEmpty ? Center(
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
                    return FoodListTile(element: foodList[index]);
                  }
              )
          );}
    });
  }

}
class FoodListTile extends StatelessWidget {
  const FoodListTile({super.key, required this.element});

  final FoodWithProductInfo element;
  @override
  Widget build(BuildContext context) {
    var color = Colors.white;
    var isOpened = element.food.openingDate == null;
    if (DateTime.now().isAfter(element.finalDate)){
      color = Colors.red;
    }
    else if (element.finalDate.difference(DateTime.now()).inDays <= 7){
      color = Colors.amber;
    }
    return Padding(
      padding: const EdgeInsets.all(10),

      child: Slidable(
          endActionPane: ActionPane(
            motion: DrawerMotion(),
            children: [
              SlidableAction(
                borderRadius: BorderRadius.horizontal(left:Radius.circular(15)),
                onPressed: (context) {

                  navigateAndDisplayAddPage(context, 0, element.product,element.food,true);
                },
                backgroundColor: Color(0xFF0392CF),
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),
              SlidableAction(
                borderRadius: BorderRadius.horizontal(right:Radius.circular(15)),
                onPressed: (context) => showDialog<String>(
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
                          var player = AudioPlayer();
                          player.play(AssetSource("EatingSound.mp3"));
                          appDb.deleteFoodRecord(element.food.id);
                          Navigator.pop(context);},
                        child: const Text('Yes'),
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
          child: Card(
              color: color,
              child:ListTile(
                  title:Row(children: [Text(element.food.name.capitalize(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),Expanded(
                    child: Container(),
                  ),
                    Text(DateFormat("E dd.MM.yyyy").format(element.finalDate))]),
                  subtitle: Text("${element.food.desc!}\n${element.finalPlace}"),
                  trailing: isOpened ?  TextButton(
                      onPressed: () {
                    FoodEntry newFood = element.food.copyWith(openingDate: Value(DateTime.now()));
                    appDb.updateFoodRecord(id: element.food.id,food: newFood);
                  },
                      child: Text("Open")
                  ): null,
              )
          )
      ),
    );
  }
}