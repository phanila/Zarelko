import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CounterField extends StatefulWidget {
  const CounterField({super.key, required this.onSaved, required this.label, this.initialValue});
  final Function(String?) onSaved;
  final String label;
  final int? initialValue;
  @override
  State<CounterField> createState() => _CounterFieldState();
}

class _CounterFieldState extends State<CounterField> {
  int count = 1;
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    count = widget.initialValue ?? 1;
    myController.text = count.toString();
    return Row(
      children: [
        IconButton(
            onPressed: () {
              count--;
              myController.text = count.toString();
            },
            icon: Icon(Icons.remove)),
        Expanded(child: TextFormField(
          maxLength: 20,
          decoration: InputDecoration(
            labelText: widget.label,
            border: OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
          controller: myController,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          onChanged: (value) {
            count = int.parse(value);
          },
          onSaved: widget.onSaved,
        )
        ),
        IconButton(
            onPressed: () {
              count++;
              myController.text = count.toString();
            },
            icon: Icon(Icons.add)),
      ],
    );
  }
}