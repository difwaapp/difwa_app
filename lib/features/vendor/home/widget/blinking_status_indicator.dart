import 'dart:async';
import 'package:difwa_app/config/theme/theme_helper.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isActive 
              ? appTheme.primaryColor
              : appTheme.secondyColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isActive 
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.isActive ? Colors.greenAccent : Colors.grey.shade400,
                shape: BoxShape.circle,
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.isActive ? "Online" : "Offline",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
