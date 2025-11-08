import 'dart:async';
import 'package:flutter/material.dart';

class BlinkingStatusIndicator extends StatefulWidget {
  final bool isActive;

  const BlinkingStatusIndicator({super.key, required this.isActive});

  @override
  State<BlinkingStatusIndicator> createState() =>
      _BlinkingStatusIndicatorState();
}

class _BlinkingStatusIndicatorState extends State<BlinkingStatusIndicator> {
  double _opacity = 1.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startBlinking();
  }

  void _startBlinking() {
    _timer?.cancel(); // Cancel any existing timer

    if (widget.isActive) {
      _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          _opacity = _opacity == 1.0 ? 0.3 : 1.0;
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant BlinkingStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _opacity = 1.0;
      _startBlinking();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: widget.isActive ? _opacity : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.isActive ? Colors.green.shade50 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              Icons.circle,
              size: 10,
              color: widget.isActive ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 5),
            Text(
              widget.isActive ? "Online" : "Offline",
              style: TextStyle(
                color: widget.isActive ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
