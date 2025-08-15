import 'package:flutter/material.dart';
import 'package:hotelmanagement/core/dialogs/generic_dialog.dart';

Future<void> showIngredientsUnavailableDialog(
  BuildContext context, String message,
) async {
  return showGenericDialog(
    context: context, 
    title: 'Ingredients Unavailable', 
    content: message, 
    optionsBuilder: () => {
      'OK': null,
    },
    );
}