import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zarelko/database/database.dart';


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
    var database = context.watch<AppDatabase>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Add Food"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formGlobalKey,
            child: ListView(
              children: [
                _buildTextFormField("Name", "You must enter a name", (value) {
                  _name = value!;
                }),
                const SizedBox(height: 12),
                _buildTextFormField("Description", "You must enter a description", (value) {
                  _desc = value!;
                }),
                const SizedBox(height: 12),
                _buildTextFormField("Type", "You must enter a type", (value) {
                  _type = value!;
                }),
                const SizedBox(height: 12),
                _buildTextFormField("Location", "You must enter a location", (value) {
                  _location = value!;
                }),
                const SizedBox(height: 12),
                _buildDateField(),
                const SizedBox(height: 20),
                _buildSubmitButton(database),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable method for creating text fields
  Widget _buildTextFormField(
      String label,
      String validationMessage,
      Function(String?) onSaved,
      ) {
    return TextFormField(
      maxLength: 20,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
      onSaved: onSaved,
    );
  }

  // Date picker field
  Widget _buildDateField() {
    return TextFormField(
      controller: _controlDate,
      decoration: const InputDecoration(
        labelText: "Expiry Date",
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          firstDate: DateTime.now().subtract(Duration(days: 365 * 5)),
          lastDate: DateTime.now().add(Duration(days: 365 * 10)),
        );
        if (pickedDate != null) {
          _expiryDate = pickedDate;
          setState(() {
            _controlDate.text = DateFormat("dd-MM-yyyy").format(pickedDate);
          });
        }
      },
      readOnly: true,
    );
  }

  // Submit button
  Widget _buildSubmitButton(AppDatabase database) {
    return FilledButton(
      onPressed: () {
        if (_formGlobalKey.currentState!.validate()) {
          _formGlobalKey.currentState!.save();
          database.addFood(
            FoodsCompanion(
              id: Value.absent(),
              name: Value(_name),
              desc: Value(_desc),
              expiryDate: Value(_expiryDate),
              category: Value(_type),
              location: Value(_location),
            ),
          );
          Navigator.pop(context, _name);
        }
      },
      child: const Text("Add Food"),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
