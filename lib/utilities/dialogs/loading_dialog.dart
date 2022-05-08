import 'package:flutter/material.dart';

// ! Tätä ei tarvita enää kun luotiin loading_screen.dart

// * Allow the caller to display and dismiss this dialog
// * Dialogin luominen palauttaa kutsujalle funktion dialogin sulkemista varten

// * A function to close the dialog
typedef CloseDialog = void Function();

CloseDialog showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    content: Column(
      // * Column ottaa normaalisti mahdollisimman paljon saatavasta tilasta (ei haluta tässä tapauksessa)
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        // * Empty space with height of 10.0
        const SizedBox(height: 10.0),
        Text(text),
      ],
    ),
  );

  showDialog(
    context: context,
    // * Dialogi ei häviä jos käyttäjä napauttaa ulkopuolelta
    barrierDismissible: false,
    // * Cancel nappi olisi myös hyvä vaikka jos sovellus tilttaa
    builder: (context) => dialog,
  );

  // * Palautetaan funktio jolla suljetaan dialog (CloseDialog)
  // ? Tämä ei tiedä mitä poppaa -> ei välttämättä meidän dialogia
  return () => Navigator.of(context).pop();
}
