import 'package:flutter/material.dart';

class McqOptions extends StatelessWidget {
  final List<String> options;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  const McqOptions({super.key, required this.options, required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: RadioListTile<int>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              tileColor: Colors.white,
              value: i,
              groupValue: selectedIndex,
              onChanged: (v) => onSelected(v!),
              title: Text(options[i]),
            ),
          ),
      ],
    );
  }
}

class EssayInput extends StatelessWidget {
  final TextEditingController controller;
  const EssayInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 12,
      decoration: const InputDecoration(
        hintText: 'Write your response here…',
        border: OutlineInputBorder(),
      ),
    );
  }
}

class ShortTextInput extends StatelessWidget {
  final TextEditingController controller;
  const ShortTextInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: 'Type your answer…',
        border: OutlineInputBorder(),
      ),
    );
  }
}

