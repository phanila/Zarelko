import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:zarelko/database/database.dart';
import 'package:zarelko/form_widget/text_field_form.dart';
import 'database/powersync.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({
    super.key,
    this.initialProduct,
    required this.title,
  });

  final Product? initialProduct;
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
          child: ProductForm(initialName: widget.initialProduct?.name,
            initialOpenLife: widget.initialProduct?.openLife,
            initialStoringLocation: widget.initialProduct?.storingLocation,
            initialOpenLocation: widget.initialProduct?.openLocation,
          title: widget.title,),
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
    required this.title,
  });

  final String? initialName;
  final int? initialOpenLife;
  final String? initialStoringLocation;
  final String? initialOpenLocation;

  final String title;

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
          },
            initialValue: _openLife.toString(),),
          const SizedBox(height: 12),
          _buildAutocompleteFormField("Where before opening",  _storingLocation,(value) {
            _storingLocation = value!;
          }),
          const SizedBox(height: 12),
          _buildAutocompleteFormField("Where after opening", _openLocation, (value) {
            _openLocation = value!;
          }),
          const SizedBox(height: 20),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildAutocompleteFormField(
      String label,
      String? initialValue,
      Function(String?) onChanged,
      ) {
    var placesList = appDb.getAllPlaces();
    TextEditingController textEditingController = TextEditingController();
    return FutureBuilder<List<String>>(
      future: placesList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<String> places = snapshot.data!;
          return Autocomplete<String>(
            fieldViewBuilder:
            ((context, textEditingController, focusNode, onFieldSubmitted) =>
                TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onFieldSubmitted: (value) => onFieldSubmitted,
                  decoration: InputDecoration(
                    labelText: label,
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  ),
                  onSaved: onChanged,
                )),
            initialValue: TextEditingValue(text: initialValue ?? ""),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return places;
              }
              // Allowing both options from the list and free text input
              var filteredPlaces = places
                  .where((String option) =>
                  option.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                  .toList();

              // Adding the typed value (in case the product is not in the list)
              if (!filteredPlaces.contains(textEditingValue.text)) {
                if (filteredPlaces.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    textEditingController.text = textEditingValue.text;
                    onChanged(textEditingValue.text);
                  });
                }
                else {
                  filteredPlaces.add(textEditingValue.text);
                }
              }
              // If there is only one match, automatically select it
              if (filteredPlaces.length == 1) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  textEditingController.text = filteredPlaces[0];
                  onChanged(filteredPlaces[0]);
                });
              }

              return filteredPlaces;
            },
            onSelected: onChanged,
          );
        }
      },
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
      child: Text(widget.title),
    );
  }
}