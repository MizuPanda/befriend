import 'package:befriend/providers/sign_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Flutter code sample for [CupertinoDatePicker].

class BirthdayPicker extends StatefulWidget {
  const BirthdayPicker({super.key});

  @override
  State<BirthdayPicker> createState() => _BirthdayPickerState();
}

class _BirthdayPickerState extends State<BirthdayPicker> {
  // This function displays a CupertinoModalPopup with a reasonable fixed height
  // which hosts CupertinoDatePicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6.0),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 12,
        ),
        const Icon(Icons.cake_rounded),
        Expanded(
          child: Consumer<SignProvider>(builder:
              (BuildContext context, SignProvider provider, Widget? child) {
            return _DatePickerItem(
              children: <Widget>[
                Text(
                  'Your Birthday',
                  style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                ),
                CupertinoButton(
                  // Display a CupertinoDatePicker in date picker mode.
                  onPressed: () => _showDialog(
                    CupertinoDatePicker(
                      initialDateTime: provider.date,
                      mode: CupertinoDatePickerMode.date,
                      use24hFormat: true,
                      // This shows day of week alongside day of month
                      showDayOfWeek: true,
                      // This is called when the user changes the date.
                      onDateTimeChanged: provider.onDateTimeChanged,
                    ),
                  ),
                  // In this example, the date is formatted manually. You can
                  // use the intl package to format the value based on the
                  // user's locale settings.
                  child: Text(
                    provider.dateText(),
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

// This class simply decorates a row of widgets.
class _DatePickerItem extends StatelessWidget {
  const _DatePickerItem({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}
