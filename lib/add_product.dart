import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:zarelko/database/database.dart';
import 'package:zarelko/form_widget/text_field_form.dart';
import 'database/powersync.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddProductPageState();
  }
}

class _AddProductPageState extends State<AddProductPage> {
  final _formGlobalKey = GlobalKey<FormState>();
  String _name = '';
  int _openLife = 1;
  String? _storingLocation;
  String? _openLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: const Text("Add Product"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formGlobalKey,
            child: ListView(
              children: [
                // name
                buildTextFormField("Name", (value) {
                  _name = value!;
                },(value) {return null;}),
                const SizedBox(height: 12),
                // desc
                buildTextFormField("How long can it be opened?", (value) {
                  _openLife = int.parse(value!);
                },(value) {
                  var res = int.tryParse(value!);
                  if (res == null) return "Not a number";
                  return null;
                }),
                const SizedBox(height: 12),
                buildTextFormField("Where before opening", (value) {
                  _storingLocation = value!;
                },(value) {return null;}),
                const SizedBox(height: 12),
                buildTextFormField("Where after opening", (value) {
                  _openLocation = value!;
                },(value) {return null;}),
                const SizedBox(height: 20),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Submit button
  Widget _buildSubmitButton() {
    return FilledButton(
      onPressed: () {
        if (_formGlobalKey.currentState!.validate()) {
          _formGlobalKey.currentState!.save();
          appDb.addProduct(
            ProductsCompanion(
              name: Value(_name),
              openLife: Value(_openLife),
              openLocation: Value(_openLocation),
              storingLocation: Value(_storingLocation),
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
      child: const Text("Add Product"),
    );
  }
}