import 'package:flutter/material.dart';

class ModernToggleSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onToggle;
  final double width;
  final double height;
  final Color activeColor;
  final Color inactiveColor;

  const ModernToggleSwitch({
    super.key,
    required this.initialValue,
    required this.onToggle,
    this.width = 70,
    this.height = 40,
    this.activeColor = const Color(0xFF4ADE80), // Modern green
    this.inactiveColor = const Color(0xFF9CA3AF), // Cool grey
  });

  @override
  _ModernToggleSwitchState createState() => _ModernToggleSwitchState();
}

class _ModernToggleSwitchState extends State<ModernToggleSwitch>
    with SingleTickerProviderStateMixin {
  late bool isToggled;
  late AnimationController _controller;
  late Animation<double> _thumbPosition;

  @override
  void initState() {
    super.initState();
    isToggled = widget.initialValue;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _thumbPosition =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    if (isToggled) _controller.value = 1.0;
  }

  void _toggleSwitch() {
    setState(() {
      isToggled = !isToggled;
      if (isToggled) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onToggle(isToggled);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double thumbSize = widget.height - 8;
    return GestureDetector(
      onTap: _toggleSwitch,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height / 2),
          gradient: LinearGradient(
            colors: isToggled
                ? [widget.activeColor, widget.activeColor.withOpacity(0.8)]
                : [widget.inactiveColor, widget.inactiveColor.withOpacity(0.7)],
          ),
          boxShadow: [
            if (isToggled)
              BoxShadow(
                color: widget.activeColor.withOpacity(0.6),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Align(
                alignment: Alignment(-1 + 2 * _thumbPosition.value, 0),
                child: child!,
              );
            },
            child: Container(
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
