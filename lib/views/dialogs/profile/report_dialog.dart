import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  final String pictureId;
  final String profileId;
  final Map<String, dynamic> sessionUsers;

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
      title: const Text('Report'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Inappropriate content'),
              value: inappropriateContent,
              onChanged: (value) {
                setState(() {
                  inappropriateContent = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Other'),
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
                decoration: const InputDecoration(
                  labelText: 'Reason',
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
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _report(context);
                },
                child: const Text('Report'),
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
            context, 'There was an unexpected error. Please try again.');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }
}
