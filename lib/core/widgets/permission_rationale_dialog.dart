import 'package:flutter/material.dart';

/// Shows an in-app explanation before the OS permission dialog.
///
/// Returns true when the user chose to continue to the system prompt,
/// false when they declined. Rationales appear only when the permission
/// is not already granted, so users who approved never see them again.
Future<bool> showPermissionRationale(
  BuildContext context, {
  required String title,
  required String message,
  String continueLabel = 'Continue',
  String cancelLabel = 'Not now',
}) async {
  final continuePressed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(continueLabel),
        ),
      ],
    ),
  );
  return continuePressed ?? false;
}