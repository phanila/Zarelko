import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zarelko/database/database.dart';
import 'package:zarelko/form_widget/text_field_form.dart';


class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddFoodPageState();
  }
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _formGlobalKey = GlobalKey<FormState>();
  String _name = '';
  String? _desc;
  String? _location;
  DateTime _expiryDate = DateTime.now().add(Duration(days: 7));
  DateTime? _openingDate;

  final TextEditingController _controlExpireDate = TextEditingController();
  final TextEditingController _controlOpeningDate = TextEditingController();

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
                // name
                _buildDropDownFormField("Name",database),
                const SizedBox(height: 12),
                // desc
                buildTextFormField("Description", (value) {
                  _desc = value!;
                },(value) {return null;}),
                const SizedBox(height: 12),
                buildTextFormField("Location", (value) {
                  _location = value!;
                },(value) {return null;}),
                // Expiry date
                const SizedBox(height: 12),
                _buildDateField("Expiry Date", (value) {
                  _expiryDate = value!;
                },_controlExpireDate),
                // Opening date
                const SizedBox(height: 12),
                _buildDateField("Opening Date", (value) {
                  _openingDate = value!;
                },_controlOpeningDate),
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


  Widget _buildDropDownFormField(
      String label,
      Function(String?) onChanged,
      AppDatabase database,
      ) {
    var productList = database.getAllProductNames();
    return FutureBuilder<List<String>>(
      future: productList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 16, horizontal: 12),
            ),
            items: snapshot.data!.map((p) {
              return DropdownMenuItem(
                value: p,
                child: Text(p),);
            }).toList()
            ..add(DropdownMenuItem(
              value: "3",
              child: TextButton(
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('AlertDialog Title'),
                    content: const Text('AlertDialog description'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                child: Text("New product")
              ),
        ),  ),
            onChanged: (value) {
            _name = value!;
            },
            validator: (value) {
              if (await database.existsProduct(name))
                return "No such product in database";
              return null;
            },
          );
        }
      },
    );
  }

  // Date picker field
  Widget _buildDateField(String label,
      Function(DateTime?) onTap, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
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
          onTap(pickedDate);
          setState(() {
            controller.text = DateFormat("dd-MM-yyyy").format(pickedDate);
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
              openingDate: Value(_openingDate),
              location: Value(_location),
            ),
          );
          Navigator.pop(context, _name);
        }
      },
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text("Add Food"),
    );
  }
}
class AutocompleteProducts extends StatelessWidget {
  const AutocompleteProducts({super.key});

  @override
  Widget build(BuildContext context) {
    var productOptions = database.ge
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return _kOptions.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        debugPrint('You just selected $selection');
      },
    );
  }
}
