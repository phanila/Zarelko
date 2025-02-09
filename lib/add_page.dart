
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'main.dart';
class AddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddPageState();
  }
}
class _AddPageState extends State<AddPage> {
  final _formGlobalKey = GlobalKey<FormState>();
  String _name = '';
  String _desc = '';
  String _type = '';
  String _location = '';
  DateTime _expiryDate = DateTime.now().add(Duration(days: 7));

  TextEditingController _controlDate = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
        resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Add food"),
      ),
      body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formGlobalKey,
            child: Column(
              children: [
                // name
                TextFormField(
                  maxLength: 20,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Name")
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'You must enter a name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                // desc
                TextFormField(
                  maxLength: 20,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Description")
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'You must enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _desc = value!;
                  },
                ),
                // type
                TextFormField(
                  maxLength: 20,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Type")
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'You must enter a type';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _type = value!;
                  },
                ),
                // location
                TextFormField(
                  maxLength: 20,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Location")
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'You must enter a location';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _location = value!;
                  },
                ),
                // date
                TextFormField(
                  controller: _controlDate,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Date")
                    ),
                  onTap:() async {
                    DateTime? pickedDate= await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(Duration(days: 365*5)),
                        lastDate: DateTime.now().add(Duration(days: 365*10))
                    );
                    if (pickedDate != null) {
                      _expiryDate = pickedDate;
                      setState(() {
                        _controlDate.text = DateFormat("dd-MM-yyyy").format(pickedDate);
                      });
                    }
                  }
                ),
                // submit button
                const SizedBox(height: 20,),
                FilledButton(
                    onPressed: (){
                      if (_formGlobalKey.currentState!.validate()) {
                        _formGlobalKey.currentState!.save();
                        appState.addFood(Food(_name, _desc, _expiryDate, _type, _location));
                        Navigator.pop(context,_name);
                      }
                    },
                    child: const Text("Add")
                )
              ],
            ),
          )
      )
      ),
    );
  }
}