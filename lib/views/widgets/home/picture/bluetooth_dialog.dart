import 'package:flutter/material.dart';

class BluetoothDialog extends StatelessWidget {
  const BluetoothDialog({
    super.key, required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: child,
    );
  }
}
