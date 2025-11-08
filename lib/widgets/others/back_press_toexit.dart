import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BackPressToExit extends StatefulWidget {
  final Widget child; // The screen you want to wrap

  const BackPressToExit({super.key, required this.child});

  @override
  _BackPressToExitState createState() => _BackPressToExitState();
}

class _BackPressToExitState extends State<BackPressToExit> {
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          Fluttertoast.showToast(
            msg: 'Press back again to exit',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          return false;
        }
        return true;
      },
      child: widget.child,
    );
  }
}
