import 'package:flutter/material.dart';

Widget buildTextFormField(
    String label,
    Function(String?) onSaved,
    Function(String?) validator,
    ) {
  return TextFormField(
    maxLength: 20,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    ),
    onSaved: onSaved,
    validator: (value) {
      return validator(value);
    },
  );
}