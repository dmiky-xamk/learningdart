import 'package:flutter/material.dart' show BuildContext, ModalRoute;

// * Lisätään BuildContextiin uusi metodi
// * jolla on mahdollista palauttaa annetut argumentit (propsit)
extension GetArgument on BuildContext {
  T? getArgument<T>() {
    final modalRoute = ModalRoute.of(this);

    if (modalRoute != null) {
      final args = modalRoute.settings.arguments;

      // * Voi olla null jos kutsuja ei anna argumentteja
      if (args != null && args is T) {
        return args as T;
      }
    }

    return null;
  }
}
