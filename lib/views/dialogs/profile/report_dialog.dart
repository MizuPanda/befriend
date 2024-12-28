import 'package:befriend/utilities/error_handling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/authentication/authentication.dart';
import '../../../utilities/app_localizations.dart';

class ReportDialog extends StatefulWidget {
  final String pictureId;
  final String profileId;
  final List<dynamic> sessionUsers;

  const ReportDialog({
    super.key,
    required this.pictureId,
    required this.profileId,
    required this.sessionUsers,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  bool inappropriateContent = false;
  bool other = false;
  TextEditingController otherReasonController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.translate(context,
          key: 'rp_report', defaultString: 'Report')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: Text(AppLocalizations.translate(context,
                  key: 'rp_inap', defaultString: 'Inappropriate content')),
              value: inappropriateContent,
              onChanged: (value) {
                setState(() {
                  inappropriateContent = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text(AppLocalizations.translate(context,
                  key: 'general_word_other', defaultString: 'Other')),
              value: other,
              onChanged: (value) {
                setState(() {
                  other = value!;
                });
              },
            ),
            if (other)
              TextField(
                controller: otherReasonController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.translate(context,
                      key: 'rp_reason', defaultString: 'Reason'),
                ),
              ),
          ],
        ),
      ),
      actions: _isLoading
          ? [const CircularProgressIndicator()]
          : [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.translate(context,
                    key: 'dialog_cancel', defaultString: 'Cancel')),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _report(context);
                },
                child: Text(AppLocalizations.translate(context,
                    key: 'rp_report', defaultString: 'Report')),
              ),
            ],
    );
  }

  Future<void> _report(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });
      if (inappropriateContent || other) {
        // Prepare the report data
        final Map<String, dynamic> reportData = {
          'sender': AuthenticationManager.id(),
          'timestamp': FieldValue.serverTimestamp(),
          'pictureId': widget.pictureId,
          'profileId': widget.profileId,
          'sessionUsers': widget.sessionUsers,
          'reasons': {
            'inappropriateContent': inappropriateContent,
            'other': other ? otherReasonController.text : null,
          },
        };

        // Upload the report to Firestore
        await FirebaseFirestore.instance.collection('reports').add(reportData);
      }
      // Close the dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('(ReportDialog) Error reporting dialog: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.translate(context,
                key: 'general_error_message6',
                defaultString:
                    'There was an unexpected error. Please try again.'));
      }
    }

    setState(() {
      _isLoading = false;
    });
  }
}
