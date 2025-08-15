import 'package:flutter/material.dart';
import 'package:hotelmanagement/core/dialogs/generic_dialog.dart';
import 'package:hotelmanagement/core/models/dish.dart';

Future<bool> showDeleteDishDialog(
  BuildContext context, {
  required Dish dish,
}) async {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete Dish',
    content: 'Are you sure you want to delete the dish "${dish.name}"?',
    optionsBuilder: () => {
      'Cancel': false,
      'Delete': true,
    },
  ).then((value) => value ?? false);
}