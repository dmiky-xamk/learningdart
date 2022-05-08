import 'package:flutter/foundation.dart' show immutable;

// ? Mahdollistaa sulkemaan latausruudun sekä päivittämään sen sisällön
typedef CloseLoadingScreen = bool Function();
typedef UpdateLoadingScreen = bool Function(String text);

@immutable
class LoadingScreenController {
  final CloseLoadingScreen close;
  final UpdateLoadingScreen update;

  const LoadingScreenController({
    required this.close,
    required this.update,
  });
}
