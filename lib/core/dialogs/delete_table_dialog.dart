import 'package:flutter/material.dart';
import 'package:hotelmanagement/core/dialogs/generic_dialog.dart';

Future<bool> showTableDeleteDialog(
  BuildContext context, {
  required String tableName,
}) async {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete Table',
    content: 'Are you sure you want to delete the table "$tableName"?',
    optionsBuilder: () => {
      'Cancel': false,
      'Delete': true,
    },
  ).then((value) => value ?? false);
}