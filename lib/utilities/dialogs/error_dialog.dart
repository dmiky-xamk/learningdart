import 'package:flutter/material.dart';
import 'generic_dialog.dart';

// * Näyttää virheilmoituksen -> nappi pelkkä ok -> sillä ei ole arvoa
Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: "An error occured",
    content: text,
    optionsBuilder: () => {
      "OK": null,
    },
  );
}
