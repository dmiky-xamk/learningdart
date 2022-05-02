import 'package:flutter/material.dart';

// * Antaa käyttäjän määritellä listan nappeja,
// * joilla on otsikko ja tyyppi
typedef DialogOptionBuilder<T> = Map<String, T?> Function();

// * Nullable sillä Androidilla voidaan klikata dialogin ulkopuolelta
Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  // * optionsBuilder on funktio, joka palauttaa funktiota
  // * kutsuessa annettavan mapin
  final options = optionsBuilder();

  return showDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: options.keys.map(
            (optionTitle) {
              // * optionTitle on key (String)
              // * options[optionTitle] on <T>
              final value = options[optionTitle];

              return TextButton(
                onPressed: () {
                  if (value != null) {
                    Navigator.of(context).pop(value);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(optionTitle),
              );
            },
          ).toList(),
        );
      });
}
