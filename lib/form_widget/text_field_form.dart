import 'package:flutter/material.dart';

Widget buildTextFormField(
    String label,
    Function(String?) onSaved,
    Function(String?) validator,
{String? initialValue}) {
  return TextFormField(
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),
    onSaved: onSaved,
    validator: (value) {
      return validator(value);
    },
    initialValue: initialValue,
  );
}