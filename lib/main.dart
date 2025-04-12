import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:core';
import 'package:zarelko/add_food.dart';
import 'package:zarelko/add_product.dart';
import 'package:zarelko/database/powersync.dart';
import 'package:zarelko/notifications_service.dart';
import 'package:zarelko/workmanger_service.dart';
import 'database/database.dart';
import 'home_page.dart';
import 'product_page.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';

import 'database/powersync.dart';
import 'notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //required to get sqlite filepath from path_provider before UI has initialized
  await openDatabase();
  await NotificationsService.init();
  initializeWorkManager();
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  var currentIndex = 0;


  var player = AudioPlayer();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        player.play(AssetSource("Zarelko.mp3"));
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");

        player.stop();
        //Stop the music
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        player.stop();
        //Stop the music
        break;
      case AppLifecycleState.hidden:
        print("app in hidden");
    }
  }
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
          ElevatedButton(onPressed: (){
            Workmanager().cancelAll();
            Workmanager().registerOneOffTask("task-identifier-simple", "simple_task");

            Workmanager().registerOneOffTask("task-identifier", "daily_expiry_check");
            scheduleDailyTaskAt9AM();
            //NotificationsService().showInstantNotification("instant", "");
            //NotificationsService.scheduleDelayedNotification("Test", "notification service",DateTime.now().add(Duration(seconds: 10)));
            //NotificationsService.getScheduledNotifications();
          }, child: Icon(Icons.sync))
        ],
      ),
      body: [HomePageBody(), ProductPageBody()][currentIndex],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
          navigateAndDisplayAddPage(context, currentIndex, null,null,false);
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

Future<void> navigateAndDisplayAddPage(BuildContext context, int currentIndex, Product? product, FoodEntry? food,bool toEdit) async {
  final destAdd = [AddFoodPage(toEdit:toEdit,initialFood: food,initialProduct: product,),AddProductPage(title:toEdit?"Edit product":"Add product",initialProduct: product,)];
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => destAdd[currentIndex]),
  );

  if (!context.mounted) return;

  // After the Selection Screen returns a result, hide any previous snackbars
  // and show the new result.
  if (result != null) {
    var name = ["food","product"];
    var prefix = toEdit? "Edited":"Added";
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${prefix} ${name[currentIndex]}: $result')));
  }
}
