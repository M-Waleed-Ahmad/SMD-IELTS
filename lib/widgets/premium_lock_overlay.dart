import 'package:flutter/material.dart';

class PremiumLockOverlay extends StatelessWidget {
  final bool locked;
  const PremiumLockOverlay({super.key, required this.locked});

  @override
  Widget build(BuildContext context) {
    if (!locked) return const SizedBox.shrink();
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.lock, color: Colors.amber),
              SizedBox(width: 6),
              Text('Premium', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

