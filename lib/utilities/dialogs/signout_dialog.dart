import 'package:flutter/material.dart';
import 'package:learningdart/extensions/buildcontext/loc.dart';
import 'package:learningdart/utilities/dialogs/generic_dialog.dart';

// * Palauttaa default valuen, jos käyttäjä ei klikkaa kumpaakaan nappia ja palautuu null
Future<bool> showSignOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.logout_button,
    content: context.loc.logout_dialog_prompt,
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.logout_button: true,
    },
  ).then(
    (value) => value ?? false,
  );
}
