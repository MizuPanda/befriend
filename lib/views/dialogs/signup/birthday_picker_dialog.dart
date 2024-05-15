import 'package:flutter/cupertino.dart';

class BirthdayPickerDialog {
  // This function displays a CupertinoModalPopup with a reasonable fixed height
  // which hosts CupertinoDatePicker.
  static Widget dialog(
    BuildContext context,
    Widget child,
  ) {
    final double height = MediaQuery.of(context).size.height;

    return Container(
      height: 0.300 * height,
      padding: EdgeInsets.only(top: 0.006 * height),
      // The Bottom margin is provided to align the popup above the system
      // navigation bar.
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      // Provide a background color for the popup.
      color: CupertinoColors.systemBackground.resolveFrom(context),
      // Use a SafeArea widget to avoid system overlaps.
      child: SafeArea(
        top: false,
        child: child,
      ),
    );
  }
}
