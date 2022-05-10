import 'package:flutter/material.dart';
import 'package:learningdart/extensions/buildcontext/loc.dart';
import 'package:learningdart/utilities/dialogs/generic_dialog.dart';

// * Palauttaa default valuen, jos käyttäjä ei klikkaa kumpaakaan nappia ja palautuu null
Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: context.loc.delete,
    content: context.loc.delete_note_prompt,
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.yes: true,
    },
  ).then(
    (value) => value ?? false,
  );
}
