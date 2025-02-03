import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/sign_provider.dart';
import 'package:befriend/views/dialogs/signup/birthday_picker_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/app_localizations.dart';

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
        builder: (BuildContext context) =>
            BirthdayPickerDialog.dialog(context, child));
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Row(
      children: [
        SizedBox(
          width: 12 / 448 * width,
        ),
        const Icon(Icons.cake_rounded),
        Expanded(
          child: Consumer<SignProvider>(builder:
              (BuildContext context, SignProvider provider, Widget? child) {
            return _DatePickerItem(
              children: [
                AutoSizeText(
                  AppLocalizations.translate(context,
                      key: 'bp_birthday', defaultString: 'Your Birthday'),
                  style: TextStyle(
                      fontSize: 18, color: Theme.of(context).hintColor),
                ),
                Expanded(
                  child: CupertinoButton(
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
                    child: AutoSizeText(
                      provider.dateText(context),
                      style: const TextStyle(
                        fontSize: 20.0,
                      ),
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
    final double height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.016 * height),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}
