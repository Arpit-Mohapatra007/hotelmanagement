import 'package:flutter/material.dart';
import 'package:hotelmanagement/core/dialogs/generic_dialog.dart';

Future<bool> showDeleteItemDialog({
  required BuildContext context,
  required String itemName,
}) async {
  return await showGenericDialog(
    context: context, 
    title: 'Delete Item', 
    content: 'Are you sure you want to delete $itemName?', 
    optionsBuilder: () => {
      'Cancel': false,
      'Delete': true,
    },
    ).then((value) => value ?? false);
}