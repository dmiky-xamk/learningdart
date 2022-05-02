import 'package:flutter/material.dart';
import 'package:learningdart/utilities/dialogs/generic_dialog.dart';

// * Palauttaa default valuen, jos käyttäjä ei klikkaa kumpaakaan nappia ja palautuu null
Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Delete",
    content: "Are you sure you want to delete this item?",
    optionsBuilder: () => {
      "Cancel": false,
      "Yes": true,
    },
  ).then(
    (value) => value ?? false,
  );
}
