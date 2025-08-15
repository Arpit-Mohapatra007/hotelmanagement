import 'package:flutter/material.dart';
import 'package:hotelmanagement/core/dialogs/generic_dialog.dart';
import 'package:hotelmanagement/core/models/order.dart';

Future<bool> showCancelAllOrderDialog(
  BuildContext context,
  List<Order> orders,
  String tableNumber,
) async{
  return await showGenericDialog(
    context: context, 
    title: 'Cancel All Orders for Table $tableNumber',
    content:
      'You are about to cancel ${orders.length} active order${orders.length > 1 ? 's' : ''}:\n${orders.map((order) => '- Order ID: ${order.orderId.split('_').last.substring(0, 8)}...').join('\n')}\n\nAre you sure you want to proceed? This action cannot be undone.',
    optionsBuilder: () => {
      'Keep Orders': false,
      'Yes, Cancel All Orders': true,
    },
    ).then(
      (value) => value ?? false,
    );
}
