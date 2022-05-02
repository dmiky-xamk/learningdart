import 'package:flutter/material.dart';
import 'package:learningdart/utilities/dialogs/generic_dialog.dart';

// * Palauttaa default valuen, jos käyttäjä ei klikkaa kumpaakaan nappia ja palautuu null
Future<bool> showSignOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Sign out",
    content: "Are you sure you want to sign out?",
    optionsBuilder: () => {
      "Cancel": false,
      "Sign out": true,
    },
  ).then(
    (value) => value ?? false,
  );
}
