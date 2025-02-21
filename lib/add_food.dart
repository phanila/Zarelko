import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zarelko/database/database.dart';
import 'package:zarelko/form_widget/text_field_form.dart';
import 'package:zarelko/notifications_service.dart';
import 'database/powersync.dart';

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
  DateTime _expiryDate = DateTime.now().add(Duration(days: 7));
  DateTime? _openingDate;
  int times = 1;

  final TextEditingController _controlExpireDate = TextEditingController();
  final TextEditingController _controlOpeningDate = TextEditingController();

  @override
  Widget build(BuildContext context) {

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
                _buildAutocompleteFormField("Name",(value) {
                  _name = value!;
                },appDb),
                const SizedBox(height: 12),
                // desc
                buildTextFormField("Description", (value) {
                  _desc = value!;
                },(value) {return null;}),
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
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable method for creating text fields


  Widget _buildAutocompleteFormField(
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
          List<String> products = snapshot.data!;
          return Autocomplete<String>(
            fieldViewBuilder:
            ((context, textEditingController, focusNode, onFieldSubmitted) =>
                TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onFieldSubmitted: (value) => onFieldSubmitted,
                  decoration: InputDecoration(
                    labelText: "Product name",
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  ),
                )),
            initialValue: TextEditingValue(text: _name),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return products;
              }
              return products.where((String option) {
                return option.contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: onChanged,
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
  Widget _buildSubmitButton() {
    return FilledButton(
      onPressed: () async {
        bool isNotInDatabase = await appDb.isNotProductInDatabase(_name);
        if (isNotInDatabase) {

        }
        if (_formGlobalKey.currentState!.validate()) {
          _formGlobalKey.currentState!.save();
          appDb.addFood(
            FoodsCompanion(
              id: Value.absent(),
              name: Value(_name),
              desc: Value(_desc),
              expiryDate: Value(_expiryDate),
              openingDate: Value(_openingDate),
            ),
          );
          NotificationsService.scheduleNotification(_name, "expires on $_expiryDate", _expiryDate.subtract(Duration(days: 7)));
          NotificationsService.scheduleNotification(_name, "expires today", _expiryDate);
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