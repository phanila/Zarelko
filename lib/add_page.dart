
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
class AddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddPageState();
  }
}
class _AddPageState extends State {
  final _formGlobalKey = GlobalKey<FormState>();
  // String _name;
  // String _desc;
  // String _type;
  // String _location;
  // DateTime _expiryDate;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Add food"),
      ),
      body: Center(
          child: Form(
            key: _formGlobalKey,
            child: Column(
              children: [
                // name
                // desc
                // type
                // location
                // date
                // submit button
                const SizedBox(height: 20,),
                FilledButton(
                    onPressed: (){},
                    child: const Text("Add")
                )
              ],
            ),
          )
      ),
    );
  }
}