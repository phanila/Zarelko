import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:zarelko/database/database.dart';
import 'package:zarelko/form_widget/text_field_form.dart';
import 'database/powersync.dart';
import 'form_widget/counter_field.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({
    super.key,
    this.initialProduct,
    this. initialCategories,
    required this.title,
  });

  final Product? initialProduct;
  final String title;
  final List<String>? initialCategories;

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
            initialCategories: widget.initialCategories,
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
    this.initialCategories,
    required this.title,
  });
  final String? initialName;
  final int? initialOpenLife;
  final String? initialStoringLocation;
  final String? initialOpenLocation;
  final List<String>? initialCategories;

  final String title;

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formGlobalKey = GlobalKey<FormState>();

  late String _name;
  String? initialName;

  late int _openLife;

  String? _storingLocation;

  String? _openLocation;

  List<String> _selectedCategories = [];


  @override
  void initState() {
    super.initState();

    // Initialize the form fields with the passed initial values, if any
    _name = widget.initialName ?? '';
    // null if a new product
    initialName = widget.initialOpenLocation != null?widget.initialName:null;
    _openLife = widget.initialOpenLife ?? 1;
    _storingLocation = widget.initialStoringLocation;
    _openLocation = widget.initialOpenLocation;
    _selectedCategories = widget.initialCategories!;
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
          CounterField(label:"How long can it be opened?", onSaved: (value) {
            _openLife = int.parse(value!);
          },
            initialValue: _openLife,),
          const SizedBox(height: 12),
          _buildAutocompleteFormField("Where before opening",  _storingLocation,(value) {
            _storingLocation = value!;
          }),
          const SizedBox(height: 12),
          _buildAutocompleteFormField("Where after opening", _openLocation, (value) {
            _openLocation = value!;
          }),
          const SizedBox(height: 12),
          CategorySelector(
            initialCategories: _selectedCategories, // Pass existing categories if editing
            fetchSuggestions: () => appDb.getAllCategories(),
            onChanged: (categories) {
              _selectedCategories = categories;
            },
          ),

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
                  filteredPlaces.insert(0, textEditingValue.text);
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
            ),initialName
          );
          await appDb.updateProductCategories(_name, _selectedCategories); // or use product ID if available
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

class CategorySelector extends StatefulWidget {
  final List<String> initialCategories;
  final Future<List<String>> Function()? fetchSuggestions;
  final void Function(List<String>) onChanged;

  const CategorySelector({
    Key? key,
    this.initialCategories = const [],
    this.fetchSuggestions,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = [...widget.initialCategories];
  }

  void _addCategory(String label) {
    label = label.trim();
    if (label.isNotEmpty && !_categories.contains(label)) {
      setState(() {
        _categories.add(label);
      });
      widget.onChanged(_categories);
      _controller.clear();
    }
  }

  void _removeCategory(String label) {
    setState(() {
      _categories.remove(label);
    });
    widget.onChanged(_categories);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Categories", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: _categories.map((cat) => Chip(
            label: Text(cat),
            onDeleted: () => _removeCategory(cat),
            deleteIcon: const Icon(Icons.cancel, size: 18),
            backgroundColor: Colors.purple.shade100,
          )).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: "Add category",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: _addCategory,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _addCategory(_controller.text),
              icon: const Icon(Icons.add),
              label: const Text("Add"),
            ),
          ],
        ),
        if (widget.fetchSuggestions != null) ...[
          const SizedBox(height: 10),
          FutureBuilder<List<String>>(
            future: widget.fetchSuggestions!(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              final available = snapshot.data!.where((cat) => !_categories.contains(cat)).toList();
              return Wrap(
                spacing: 6,
                children: available.map((cat) => ActionChip(
                  label: Text(cat),
                  onPressed: () => _addCategory(cat),
                  backgroundColor: Colors.grey.shade300,
                )).toList(),
              );
            },
          ),
        ],
      ],
    );
  }
}
