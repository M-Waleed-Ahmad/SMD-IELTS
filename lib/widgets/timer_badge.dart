import 'dart:async';
import 'package:flutter/material.dart';

class TimerBadge extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onFinished;

  const TimerBadge({super.key, required this.duration, this.onFinished});

  @override
  State<TimerBadge> createState() => _TimerBadgeState();
}

class _TimerBadgeState extends State<TimerBadge> {
  late Duration remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    remaining = widget.duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (remaining.inSeconds <= 1) {
          remaining = Duration.zero;
          t.cancel();
          widget.onFinished?.call();
        } else {
          remaining = Duration(seconds: remaining.inSeconds - 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    final mm = two(remaining.inMinutes.remainder(60));
    final ss = two(remaining.inSeconds.remainder(60));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 16),
          const SizedBox(width: 6),
          Text('$mm:$ss', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

