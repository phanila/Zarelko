import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:zarelko/database/database.dart';
import 'package:zarelko/form_widget/text_field_form.dart';
import 'database/powersync.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({
    super.key,
    this.initialName,
    this.initialOpenLife,
    this.initialStoringLocation,
    this.initialOpenLocation,
    required this.title,
  });

  final String? initialName;
  final int? initialOpenLife;
  final String? initialStoringLocation;
  final String? initialOpenLocation;
  final String title;

  @override
  State<StatefulWidget> createState() {
    return _AddProductPageState();
  }
}

class _AddProductPageState extends State<AddProductPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ProductForm(initialName: widget.initialName,
            initialOpenLife: widget.initialOpenLife,
            initialStoringLocation: widget.initialStoringLocation,
            initialOpenLocation: widget.initialOpenLocation,),
        ),
      ),
    );
  }

}

class ProductForm extends StatefulWidget {
  const ProductForm({
    super.key,
    this.initialName,
    this.initialOpenLife,
    this.initialStoringLocation,
    this.initialOpenLocation,
  });

  final String? initialName;
  final int? initialOpenLife;
  final String? initialStoringLocation;
  final String? initialOpenLocation;

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formGlobalKey = GlobalKey<FormState>();

  late String _name;

  late int _openLife;

  String? _storingLocation;

  String? _openLocation;

  @override
  void initState() {
    super.initState();

    // Initialize the form fields with the passed initial values, if any
    _name = widget.initialName ?? '';
    _openLife = widget.initialOpenLife ?? 1;
    _storingLocation = widget.initialStoringLocation;
    _openLocation = widget.initialOpenLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formGlobalKey,
      child: ListView(
        children: [
          // name
          buildTextFormField("Name", (value) {
            _name = value!;
          },(value) {return null;},
            initialValue: _name,),
          const SizedBox(height: 12),
          // desc
          buildTextFormField("How long can it be opened?", (value) {
            _openLife = int.parse(value!);
          },(value) {
            var res = int.tryParse(value!);
            if (res == null) return "Not a number";
            return null;
          },),
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
    );
  }

  // Submit button
  Widget _buildSubmitButton() {
    return FilledButton(
      onPressed: () async {
        if (_formGlobalKey.currentState!.validate()) {
          _formGlobalKey.currentState!.save();
          await appDb.addOrUpdateProduct(
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