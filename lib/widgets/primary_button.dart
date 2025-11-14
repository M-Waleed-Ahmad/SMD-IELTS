import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  const PrimaryButton({super.key, required this.label, this.onPressed, this.icon, this.expand = true});

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.play_arrow_rounded),
      label: Text(label),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

