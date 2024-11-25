import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(child: CircularProgressIndicator()),
  );
}

void hideLoadingDialog(BuildContext context) {
  if (Navigator.canPop(context)) Navigator.pop(context);
}
